import os
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import Mock, patch

from runtime import Controller, Gamescope, launch_game, process_state
from test_policy import config
from test_runtime import FakeX


def cardinal(value, property_type=6, format=32):
    return SimpleNamespace(property_type=property_type, format=format, value=value)


class MappingX(FakeX):
    def __init__(self):
        super().__init__()
        self.Xatom = SimpleNamespace(CARDINAL=6)
        self.metadata = {
            ':0': {'GAMESCOPE_PID': cardinal([100]), 'GAMESCOPE_XWAYLAND_SERVER_ID': cardinal([0])},
            ':1': {'GAMESCOPE_PID': cardinal([100]), 'GAMESCOPE_XWAYLAND_SERVER_ID': cardinal([1])},
        }

    def prop(self, name):
        return self.metadata[os.environ['DISPLAY']].get(name)

    def display_properties(self, display_name):
        return self.metadata[display_name]

    def snapshot(self):
        return {**super().snapshot(), 'display': ':1'}


class MappingRegressionTests(unittest.TestCase):
    def setUp(self):
        self.enterContext(patch.dict(os.environ, {'DISPLAY': ':0'}, clear=True))
        self.x = MappingX()
        self.controller = Controller(config(), self.x)
        self.controller.read_physical = lambda: None
        self.controller.power_request = lambda watts: None

    def test_no_environment_mapping_launch_uses_official_root_id(self):
        status = self.controller.tick({'app': '883710', 'display': ':1', 'mapping': {}})
        self.assertIn(('GAMESCOPE_XWAYLAND_MODE_CONTROL', [1, 1280, 800, 1]), self.x.writes)
        self.assertFalse(status['pending_game_resolution'])
        self.assertEqual(status['game_mapping'], {'source': 'gamescope-root-properties', 'compositor_pid': 100, 'server_index': 1})
        self.assertTrue(status['virtual_resolution_submitted'])
        self.assertIsNone(status['actual_game_frame'])

    def test_matching_geometry_before_first_submission_is_pending(self):
        status = self.controller.tick()
        self.assertEqual(status['virtual_root_size'], {'width': 1280, 'height': 800})
        self.assertTrue(status['pending_game_resolution'])
        self.assertEqual(self.x.writes, [])
        self.assertFalse(status['virtual_resolution_submitted'])

    def test_matching_geometry_without_verified_submission_stays_pending(self):
        self.x.focused = [883710]
        self.x.running = {'883710'}
        self.x.metadata[':1'] = {}
        self.controller.tick()
        status = self.controller.tick()
        self.assertEqual(status['virtual_root_size'], {'width': 1280, 'height': 800})
        self.assertTrue(status['pending_game_resolution'])
        self.assertIsNone(status['game_mapping'])
        self.assertFalse(status['virtual_resolution_submitted'])

    def test_display_number_is_not_server_index(self):
        self.x.metadata[':42'] = self.x.metadata[':1']
        self.controller.game_display = ':42'
        self.controller.apply_virtual(config()['profiles']['handheld-battery'])
        self.assertEqual(self.x.writes, [('GAMESCOPE_XWAYLAND_MODE_CONTROL', [1, 1280, 800, 1])])

    def test_bad_metadata_never_submits_virtual_control(self):
        invalid = (None, cardinal([1], property_type=31), cardinal([1], format=8),
                   cardinal([]), cardinal([1, 1]), cardinal([-1]), cardinal([True]))
        for display_name in (':0', ':1'):
            for name in ('GAMESCOPE_PID', 'GAMESCOPE_XWAYLAND_SERVER_ID'):
                cases = (*invalid, cardinal([0 if name == 'GAMESCOPE_PID' else 2]))
                for prop in cases:
                    with self.subTest(display=display_name, name=name, prop=prop):
                        x = MappingX()
                        x.metadata[display_name][name] = prop
                        self.controller.x = x
                        self.controller.game_display = ':1'
                        with self.assertRaises(ValueError):
                            self.controller.apply_virtual(config()['profiles']['handheld-battery'])
                        self.assertEqual(x.writes, [])

    def test_foreign_pid_and_nonzero_controller_root_rejected(self):
        for display_name, name, value in ((':1', 'GAMESCOPE_PID', 101),
                                          (':0', 'GAMESCOPE_XWAYLAND_SERVER_ID', 1)):
            with self.subTest(display=display_name):
                self.x = MappingX()
                self.x.metadata[display_name][name] = cardinal([value])
                self.controller.x = self.x
                with self.assertRaises(ValueError):
                    self.controller.tick({'app': '883710', 'display': ':1', 'mapping': {}})
                self.assertEqual(self.x.writes, [])

    def test_arbitrary_readable_root_properties_are_not_proof(self):
        self.x.metadata[':1'] = {'GAMESCOPE_FOCUSED_APP': cardinal([883710])}
        with self.assertRaises(ValueError):
            self.controller.tick({'app': '883710', 'display': ':1', 'mapping': {}})
        self.assertEqual(self.x.writes, [])

    def test_live_missing_proof_retries_with_backoff_without_repeating_other_operations(self):
        now = 100.0
        with patch('runtime.time.monotonic', side_effect=lambda: now), patch(
            'runtime.time.clock_gettime', side_effect=lambda _: now
        ):
            self.controller.suspend_offset = 0
            original = self.x.metadata[':1']
            self.x.metadata[':1'] = {}
            self.controller.tick()
            status = self.controller.tick()
            self.assertTrue(status['pending_game_resolution'])
            before = self.x.writes.copy()
            self.x.metadata[':1'] = original
            self.assertTrue(self.controller.tick()['pending_game_resolution'])
            self.assertEqual(self.x.writes, before)
            now += 1
            self.assertFalse(self.controller.tick()['pending_game_resolution'])
            self.assertEqual(self.x.writes, before + [('GAMESCOPE_XWAYLAND_MODE_CONTROL', [1, 1280, 800, 1])])

    def test_malformed_or_conflicting_hints_are_not_bypassed(self):
        for mapping in (None, [], {'DISPLAY': ':1'}, {'STEAM_GAME_DISPLAY_0': 'host:1'},
                        {'STEAM_GAME_DISPLAY_0': ':1', 'STEAM_GAME_DISPLAY_1': ':1'},
                        {'STEAM_GAME_DISPLAY_1': ':1'},
                        {'STEAM_GAME_DISPLAY_0': ':0', 'STEAM_GAME_DISPLAY_1': ':1'},
                        {'STEAM_GAME_DISPLAY_0': ':42', 'STEAM_GAME_DISPLAY_1': ':1'},
                        {'STEAM_GAME_DISPLAY_0': ':42'}):
            with self.subTest(mapping=mapping), self.assertRaises(ValueError):
                self.controller.tick({'app': '883710', 'display': ':1', 'mapping': mapping})
        self.assertEqual(self.x.writes, [])

    def test_nonlocal_display_rejected_before_connection(self):
        with patch.object(self.x, 'display_properties') as connect:
            for display_name in ('host:1', 'localhost:1', '', ':1;bad', None):
                with self.subTest(display=display_name), self.assertRaises(ValueError):
                    self.x.resolve_display(display_name, {})
            connect.assert_not_called()

    def test_unwrapped_pressure_vessel_candidates_need_no_steam_display_vars(self):
        self.x.focused = [883710]
        self.x.running = {'883710'}
        original = self.x.snapshot
        for wayland_names in (['/run/pressure-vessel/gamescope-socket'],
                              ['/run/pressure-vessel/gamescope-socket', 'gamescope-0']):
            with self.subTest(wayland_names=wayland_names), tempfile.TemporaryDirectory() as directory:
                for pid, wayland in enumerate(wayland_names, 100):
                    process = Path(directory) / str(pid)
                    process.mkdir()
                    (process / 'environ').write_bytes(f'SteamAppId=883710\0DISPLAY=:1\0GAMESCOPE_WAYLAND_DISPLAY={wayland}\0'.encode())
                apps, mappings = process_state(directory)
                self.assertEqual(apps, {'883710'})
                self.assertEqual(mappings['883710'], {'display': ':1', 'mapping': {}})
                self.x.snapshot = lambda: {**original(), 'display': None, 'mappings': mappings}
                self.controller.tick()
                status = self.controller.tick()
                self.assertFalse(status['pending_game_resolution'])
                self.assertIn(('GAMESCOPE_XWAYLAND_MODE_CONTROL', [1, 1280, 800, 1]), self.x.writes)

    def test_matching_wayland_name_does_not_authorize_foreign_xserver(self):
        self.x.metadata[':1']['GAMESCOPE_PID'] = cardinal([101])
        original = self.x.snapshot
        self.x.snapshot = lambda: {**original(), 'display': None,
                                   'mappings': {'123': {'display': ':1', 'mapping': {}}}}
        self.controller.tick()
        status = self.controller.tick()
        self.assertTrue(status['pending_game_resolution'])
        self.assertFalse(any(name == 'GAMESCOPE_XWAYLAND_MODE_CONTROL' for name, _ in self.x.writes))

    def test_old_submission_does_not_confirm_new_session_or_profile(self):
        self.controller.tick({'app': '883710', 'display': ':1', 'mapping': {}})
        profile = config()['profiles']['handheld-battery']
        for metadata in self.x.metadata.values():
            metadata['GAMESCOPE_PID'] = cardinal([200])
        status = self.controller.status(self.x.snapshot(), '883710', 'handheld-battery', profile)
        self.assertTrue(status['pending_game_resolution'])
        self.controller.tick()
        self.assertFalse(self.controller.status(self.x.snapshot(), '883710', 'handheld-battery', profile)['pending_game_resolution'])
        changed = {**profile, 'game': {'width': 1024, 'height': 768}}
        self.x.size = changed['game']
        self.assertTrue(self.controller.status(self.x.snapshot(), '883710', 'handheld-battery', changed)['pending_game_resolution'])

    def test_inaccessible_mapping_launch_still_executes_original_command(self):
        def handshake(*_):
            with patch.dict(os.environ, {'DISPLAY': ':0'}):
                return self.controller.tick({'app': '883710', 'display': ':1', 'mapping': {}})

        with patch.object(self.x, 'display_properties', side_effect=RuntimeError('inaccessible')), patch.dict(
            os.environ, {'XDG_CURRENT_DESKTOP': 'gamescope', 'SteamAppId': '883710', 'DISPLAY': ':1', 'XDG_RUNTIME_DIR': '/unused'}
        ), patch('runtime.socket.socket'), patch('runtime.os.execvpe') as execute, patch('runtime.log') as log, patch(
            'runtime.request', side_effect=handshake
        ):
            launch_game(['game', 'literal argument'])
        execute.assert_called_once()
        self.assertEqual(execute.call_args.args[:2], ('game', ['game', 'literal argument']))
        self.assertEqual(log.call_args.args[0], 'LAUNCH-HANDSHAKE-FAILED')
        self.assertIn('inaccessible', log.call_args.kwargs['error'])
        self.assertEqual(self.x.writes, [])


class XClientTests(unittest.TestCase):
    def test_properties_are_read_from_candidate_root_and_connection_closed(self):
        root = Mock()
        root.get_full_property.side_effect = [cardinal([100]), cardinal([1])]
        connection = Mock()
        connection.screen.return_value.root = root
        connection.intern_atom.side_effect = lambda name: name
        factory = Mock(return_value=connection)
        x = Gamescope.__new__(Gamescope)
        x.X = SimpleNamespace(AnyPropertyType=0)
        x.xerrors = (OSError,)
        with patch.dict('sys.modules', {'Xlib': SimpleNamespace(display=SimpleNamespace(Display=factory))}):
            properties = x.display_properties(':42')
            factory.assert_called_once_with(':42')
            self.assertEqual(properties['GAMESCOPE_XWAYLAND_SERVER_ID'].value, [1])
            self.assertEqual([call.args for call in root.get_full_property.call_args_list],
                             [('GAMESCOPE_PID', 0), ('GAMESCOPE_XWAYLAND_SERVER_ID', 0)])
            connection.close.assert_called_once()
            root.get_full_property.side_effect = OSError('inaccessible')
            with self.assertRaises(RuntimeError):
                x.display_properties(':42')
            self.assertEqual(connection.close.call_count, 2)
            factory.side_effect = OSError('connection refused')
            with self.assertRaises(RuntimeError):
                x.display_properties(':42')
            self.assertEqual(connection.close.call_count, 2)


if __name__ == '__main__':
    unittest.main()
