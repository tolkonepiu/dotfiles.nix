import os
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

from runtime import Controller, Gamescope, import_environment, launch_game, process_state, property_text
from test_policy import config


class FakeX(Gamescope):
    def __init__(self):
        self.writes = []
        self.screen = "handheld"
        self.focused = [123]
        self.running = {"123"}
        self.size = {"width": 1280, "height": 800}
        self.Xatom = SimpleNamespace(CARDINAL=6)
        self.metadata = {
            ':7': {'GAMESCOPE_PID': self.cardinal([100]), 'GAMESCOPE_XWAYLAND_SERVER_ID': self.cardinal([0])},
            ':42': {'GAMESCOPE_PID': self.cardinal([100]), 'GAMESCOPE_XWAYLAND_SERVER_ID': self.cardinal([1])},
        }

    @staticmethod
    def cardinal(value, property_type=6, format=32):
        return SimpleNamespace(property_type=property_type, format=format, value=value)

    def prop(self, name):
        return self.metadata.get(os.environ.get('DISPLAY'), {}).get(name)

    def display_properties(self, display_name):
        return self.metadata.get(display_name, {})

    def snapshot(self):
        return {"screen": self.screen, "power": "battery", "focused": self.focused,
                "running": self.running, "display": ":42", "connector": {}, "modes": ""}

    def write(self, name, values):
        self.writes.append((name, values))

    def values(self, name):
        return next((v for n, v in reversed(self.writes) if n == name), None)

    def geometry(self, display, window=None):
        return self.size.copy()


class RuntimeTests(unittest.TestCase):
    def controller(self):
        x = FakeX()
        controller = Controller(config(), x)
        controller.read_physical = lambda: None
        controller.power_request = lambda watts: {"caps_uw": {"stapm": watts * 1000000}, "errors": []}
        return x, controller

    @patch.dict(os.environ, {"DISPLAY": ":7", "STEAM_GAME_DISPLAY_0": ":42"})
    def test_launch_handshake_and_overlay_idempotency(self):
        x, controller = self.controller()
        status = controller.tick({"app": "123", "display": ":42", "mapping": {"STEAM_GAME_DISPLAY_0": ":42"}})
        self.assertFalse(status["pending_game_resolution"])
        self.assertIsNone(status["actual_game_frame"])
        self.assertIn(("GAMESCOPE_XWAYLAND_MODE_CONTROL", [1, 1280, 800, 1]), x.writes)
        before = list(x.writes)
        x.focused = [769]
        status = controller.tick()
        self.assertEqual(status["active_app_id"], "123")
        self.assertEqual(x.writes, before)
        x.running = set()
        controller.tick()
        controller.tick()
        self.assertIsNone(controller.game.app)

    @patch.dict(os.environ, {"DISPLAY": ":7", "STEAM_GAME_DISPLAY_0": ":42"})
    def test_unknown_screen_no_writes(self):
        x, controller = self.controller()
        x.screen = None
        status = controller.tick({"app": "123", "display": ":42", "mapping": {"STEAM_GAME_DISPLAY_0": ":42"}})
        self.assertEqual(x.writes, [])
        self.assertIsNone(status["selected_profile"])
        self.assertTrue(status["errors"])

    @patch.dict(os.environ, {"DISPLAY": ":7"}, clear=True)
    def test_session_without_game_mapping_wrapper_supplies_mapping(self):
        x, controller = self.controller()
        controller.tick({"app": "123", "display": ":42", "mapping": {"STEAM_GAME_DISPLAY_0": ":42"}})
        self.assertIn(("GAMESCOPE_XWAYLAND_MODE_CONTROL", [1, 1280, 800, 1]), x.writes)
        self.assertEqual(os.environ["DISPLAY"], ":7")
        self.assertNotIn("STEAM_GAME_DISPLAY_0", os.environ)

    @patch.dict(os.environ, {"DISPLAY": ":7", "GAMESCOPE_WAYLAND_DISPLAY": "gamescope-0"}, clear=True)
    def test_unwrapped_game_mapping_from_same_user_process(self):
        with tempfile.TemporaryDirectory() as directory:
            process = Path(directory) / "123"
            process.mkdir()
            (process / "environ").write_bytes(b"SteamAppId=123\0DISPLAY=:42\0STEAM_GAME_DISPLAY_0=:42\0GAMESCOPE_WAYLAND_DISPLAY=gamescope-0\0")
            apps, mappings = process_state(directory)
        self.assertEqual(apps, {"123"})
        self.assertEqual(mappings["123"]["mapping"], {"STEAM_GAME_DISPLAY_0": ":42"})
        x, controller = self.controller()
        original = x.snapshot
        x.snapshot = lambda: {**original(), "mappings": mappings}
        controller.tick()
        controller.tick()
        self.assertIn(("GAMESCOPE_XWAYLAND_MODE_CONTROL", [1, 1280, 800, 1]), x.writes)
        self.assertEqual(os.environ["DISPLAY"], ":7")

    def test_power_readback_drift_reapplied_once_and_confirmed(self):
        controller = Controller(config(), FakeX())
        controller.power = SimpleNamespace()
        controller.power_watts = 12
        controller.power_target = 12
        drift = {"caps_uw": {"power1_cap": 15000000, "power2_cap": 15000000}, "errors": []}
        correct = {"caps_uw": {"power1_cap": 12000000, "power2_cap": 12000000}, "errors": []}
        with patch("runtime.request", side_effect=[drift, correct]) as exchange:
            self.assertTrue(controller.power_request(12)["confirmed"])
        self.assertEqual([call.args[1] for call in exchange.call_args_list], [{"op": "read"}, {"watts": 12}])
        with patch("runtime.request", return_value=drift) as exchange:
            self.assertFalse(controller.power_request(12)["confirmed"])
            self.assertFalse(controller.power_request(12)["confirmed"])
        self.assertEqual([call.args[1] for call in exchange.call_args_list], [{"op": "read"}, {"op": "read"}])
        self.assertTrue(any("TDP readback" in error for error in controller.errors))

    @patch.dict(os.environ, {"DISPLAY": ":7"}, clear=True)
    def test_physical_fallback_preserves_independent_game_target(self):
        x, controller = self.controller()
        profile = config()["profiles"]["external-ac"]
        controller.requested = profile
        controller.game_display = ":42"
        controller.game_mapping = {"STEAM_GAME_DISPLAY_0": ":42"}
        controller.physical_target = {"connector": "HDMI-A-1", "width": 1280, "height": 720, "hz": 60}
        controller.read_physical = lambda: [{"name": "HDMI-A-1", "width": 1280, "height": 720, "hz": 59.94}]
        controller.physical = lambda snapshot, selected: None
        controller.apply(x.snapshot(), profile)
        self.assertIn(("GAMESCOPE_XWAYLAND_MODE_CONTROL", [1, 1600, 900, 1]), x.writes)
        self.assertEqual(controller.effective_filter, "linear")
        x.size = profile["game"].copy()
        status = controller.status(x.snapshot(), "123", "external-ac", profile)
        self.assertEqual(status["physical_confirmation"], "confirmed")
        self.assertFalse(status["pending_game_resolution"])
        controller.read_physical = lambda: [{"name": "HDMI-A-1", "width": 3840, "height": 2160, "hz": 60}]
        self.assertEqual(controller.status(x.snapshot(), "123", "external-ac", profile)["physical_confirmation"], "mismatch")
        controller.read_physical = lambda: None
        self.assertEqual(controller.status(x.snapshot(), "123", "external-ac", profile)["physical_confirmation"], "unknown")

    def test_legacy_scaling_change_is_reported_not_rewritten(self):
        x, controller = self.controller()
        controller.requested = config()["profiles"]["handheld-battery"]
        status = controller.status({**x.snapshot(), "legacy_serial": 1}, "123", "handheld-battery", controller.requested)
        self.assertEqual(status["scaling_filter_confirmation"], "unknown")
        self.assertTrue(any("legacy scaling" in error for error in status["errors"]))
        self.assertEqual(x.writes, [])

    def test_environment_is_not_shell(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "environment"
            path.write_text("DISPLAY=:7\nEVIL=yes\nXAUTHORITY=$(touch /no)\nexport DISPLAY=:9\n")
            with patch.dict(os.environ, {}, clear=True):
                import_environment(path)
                self.assertEqual(os.environ["DISPLAY"], ":7")
                self.assertNotIn("EVIL", os.environ)
                self.assertEqual(os.environ["XAUTHORITY"], "$(touch /no)")

    @patch.dict(os.environ, {"DISPLAY": ":7"}, clear=True)
    def test_short_resume_reapplies_once_without_profile_change(self):
        with patch("runtime.time.monotonic", return_value=100), patch(
            "runtime.time.clock_gettime", side_effect=[100, 100, 100, 100.2, 100.2]
        ):
            x, controller = self.controller()
            controller.tick({"app": "123", "display": ":42", "mapping": {"STEAM_GAME_DISPLAY_0": ":42"}})
            before = len(x.writes)
            controller.tick()
            self.assertEqual(len(x.writes), before)
            controller.tick()
            self.assertGreater(len(x.writes), before)
            after_resume = len(x.writes)
            controller.tick()
            self.assertEqual(len(x.writes), after_resume)

    def test_focus_display_cardinal_bytes(self):
        value = int.from_bytes(b":42\0", os.sys.byteorder)
        self.assertEqual(property_text(SimpleNamespace(format=32, value=[value])), ":42")

    @patch("runtime.os.execvpe")
    def test_niri_launch_preserves_argv(self, execute):
        with patch.dict(os.environ, {"XDG_CURRENT_DESKTOP": "niri", "GAMESCOPE_WAYLAND_DISPLAY": "stale-session"}, clear=True):
            launch_game(["--", "/game path", "literal;$(no)", "a b"])
        self.assertEqual(execute.call_args.args[:2], ("/game path", ["/game path", "literal;$(no)", "a b"]))

    @patch("runtime.log")
    @patch("runtime.os.execvpe")
    def test_handshake_failure_still_executes(self, execute, log):
        with patch.dict(os.environ, {"XDG_CURRENT_DESKTOP": "gamescope"}, clear=True):
            launch_game(["game"])
        execute.assert_called_once()
        self.assertEqual(log.call_args.args[0], "LAUNCH-HANDSHAKE-FAILED")


if __name__ == "__main__":
    unittest.main()
