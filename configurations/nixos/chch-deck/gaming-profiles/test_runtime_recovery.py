import os
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import Mock, patch

from runtime import Controller, Gamescope
from test_policy import config
from test_runtime import FakeX


def caps(watts, errors=None):
    return {"caps_uw": {"power1_cap": watts * 1000000, "power2_cap": watts * 1000000}, "errors": errors or []}


class RecoveryTests(unittest.TestCase):
    def setUp(self):
        self.now = 100.0
        self.boot = 100.0
        self.enterContext(patch("runtime.time.monotonic", side_effect=lambda: self.now))
        self.enterContext(patch("runtime.time.clock_gettime", side_effect=lambda _: self.boot))
        self.log = self.enterContext(patch("runtime.log"))
        self.enterContext(patch.dict(os.environ, {"DISPLAY": ":7"}))
        self.x = FakeX()
        self.controller = Controller(config(), self.x)
        self.controller.read_physical = lambda: None
        self.controller.power = Mock()
        self.messages = []
        self.actual = 15
        self.failures = []

        def exchange(_stream, message):
            self.messages.append(message)
            if "watts" in message:
                failure = self.failures.pop(0) if self.failures else None
                if isinstance(failure, Exception):
                    raise failure
                if failure:
                    return caps(self.actual, [failure])
                self.actual = message["watts"]
            return caps(self.actual)

        self.enterContext(patch("runtime.request", side_effect=exchange))
        self.enterContext(patch("runtime.socket.socket", return_value=Mock()))

    def advance(self, seconds):
        self.now += seconds
        self.boot += seconds

    def sets(self):
        return [m["watts"] for m in self.messages if "watts" in m]

    def events(self, event, phase=None):
        return [call.kwargs for call in self.log.call_args_list
                if call.args == (event,) and (phase is None or call.kwargs.get("phase") == phase)]

    def test_power_diagnostics_timestamp_io_without_moving_backoff_origin(self):
        def delayed_exchange(_stream, message):
            self.messages.append(message)
            self.advance(0.5)
            return caps(15, ["busy"])

        with patch("runtime.request", side_effect=delayed_exchange):
            self.assertFalse(self.controller.power_request(12)["confirmed"])
        request, = self.events("power-apply", "request")
        result, = self.events("power-apply", "result")
        self.assertEqual(request["monotonic"], 100.0)
        self.assertEqual(result["monotonic"], 100.5)
        self.assertEqual(result["retry_at"], 101.0)
        self.assertEqual(self.controller.power_retry_at, 101.0)
        self.controller.power_request(12)
        self.advance(0.5)
        self.assertTrue(self.controller.power_request(12)["confirmed"])
        self.assertEqual(self.messages, [{"watts": 12}, {"op": "read"}, {"watts": 12}])

    def test_power_diagnostics_deduplicate_connection_failures_not_attempts(self):
        stream = Mock()
        stream.connect.side_effect = [OSError("unavailable"), OSError("unavailable"),
                                      OSError("unavailable"), OSError("permission denied"), None, None]
        self.controller.power = None
        with patch("runtime.socket.socket", return_value=stream):
            for _ in range(4):
                self.assertIsNone(self.controller.power_request(12))
            failures = self.events("power-connection-failed")
            self.assertEqual([e["errors"] for e in failures],
                             [["power: unavailable"], ["power: permission denied"]])
            self.assertEqual(self.messages, [])
            self.assertEqual(self.controller.power_retry_at, 101.0)
            self.controller.power_request(12)
            self.advance(1)
            self.assertTrue(self.controller.power_request(12)["confirmed"])
            self.failures = [OSError("permission denied")]
            self.assertIsNone(self.controller.power_request(10))
            self.controller.power_request(10)
            self.advance(1)
            self.assertTrue(self.controller.power_request(10)["confirmed"])
        self.assertEqual(stream.connect.call_count, 6)
        self.assertEqual([e["reconnect"] for e in self.events("power-connected")], [False, True])
        lost, = self.events("power-connection-lost")
        self.assertEqual(lost["errors"], ["power: permission denied"])
        self.assertEqual(len(self.events("power-connection-failed")), 2)
        self.assertEqual(self.messages, [{"op": "read"}, {"watts": 12}, {"watts": 10},
                                        {"op": "read"}, {"watts": 10}])

    def test_power_diagnostics_show_invisible_correction_and_guard_once(self):
        initial = self.controller.power_request(12)
        self.controller.power_request(12)
        quiet_count = self.log.call_count
        self.controller.power_request(12)
        self.assertEqual(self.log.call_count, quiet_count)
        self.actual = 15
        self.assertEqual(self.controller.power_request(12), initial)
        self.controller.power_request(12)
        self.actual = 15
        for _ in range(4):
            self.advance(30)
            self.assertFalse(self.controller.power_request(12)["confirmed"])
        self.assertEqual(self.messages, [{"watts": 12}, {"op": "read"}, {"op": "read"},
                                        {"op": "read"}, {"watts": 12}, {"op": "read"},
                                        *[{"op": "read"}] * 4])
        requests = self.events("power-apply", "request")
        outcomes = self.events("power-apply", "result")
        self.assertEqual([e["reason"] for e in requests], ["target", "corrective"])
        self.assertIsNone(requests[0]["observed_caps_uw"])
        self.assertEqual(requests[1]["observed_caps_uw"], caps(15)["caps_uw"])
        for outcome in outcomes:
            self.assertEqual(outcome["monotonic"], 100.0)
            self.assertEqual(outcome["requested_watts"], 12)
            self.assertEqual(outcome["observed_caps_uw"], caps(12)["caps_uw"])
            self.assertTrue(outcome["confirmed"])
            self.assertEqual(outcome["errors"], [])
        self.assertTrue(outcomes[-1]["correction_used"])
        exhausted, = self.events("power-guard-exhausted")
        self.assertEqual(exhausted["monotonic"], 130.0)
        self.assertEqual(exhausted["observed_caps_uw"], caps(15)["caps_uw"])
        self.assertFalse(exhausted["confirmed"])
        self.assertTrue(any("budget exhausted" in error for error in exhausted["errors"]))
        self.assertEqual(self.log.call_count, 5)

    def test_power_diagnostics_target_change_and_resume_reset_only_existing_budget(self):
        self.launch()
        target = self.sets()[-1]
        other = 15 if target != 15 else 12
        self.actual = other
        self.controller.power_request(target)
        self.actual = other
        self.controller.power_request(target)
        self.assertEqual(len(self.events("power-guard-exhausted")), 1)
        # Resume reapplies the selected profile even when the clock has not advanced.
        self.boot += 1
        self.assertTrue(self.controller.tick()["tdp"]["confirmed"])
        reset, = self.events("power-resume-reset")
        self.assertEqual(reset["requested_watts"], target)
        self.assertTrue(reset["correction_used"])
        self.actual = other
        self.controller.power_request(target)
        self.actual = other
        self.controller.power_request(target)
        self.controller.power_request(target)
        self.assertEqual(len(self.events("power-guard-exhausted")), 2)
        self.controller.power_request(other)
        self.actual = target
        self.controller.power_request(other)
        self.actual = target
        self.controller.power_request(other)
        self.assertEqual(len(self.events("power-guard-exhausted")), 3)
        self.assertEqual(self.messages, [{"watts": target}, {"op": "read"}, {"watts": target},
                                        {"op": "read"}, {"watts": target}, {"op": "read"},
                                        {"watts": target}, {"op": "read"}, {"op": "read"},
                                        {"watts": other}, {"op": "read"}, {"watts": other}, {"op": "read"}])

    def test_power_diagnostics_reconnect_preserves_read_during_backoff(self):
        self.controller.power = None
        self.controller.power_request(12)
        self.failures = [OSError("disconnected")]
        self.assertIsNone(self.controller.power_request(10))
        self.controller.power_request(10)
        self.advance(1)
        self.assertTrue(self.controller.power_request(10)["confirmed"])
        self.assertEqual(self.messages, [{"watts": 12}, {"watts": 10}, {"op": "read"}, {"watts": 10}])
        self.assertEqual([e["reconnect"] for e in self.events("power-connected")], [False, True])
        lost, = self.events("power-connection-lost")
        self.assertEqual(lost["requested_watts"], 10)
        self.assertEqual(lost["retry_at"], 101.0)
        self.assertEqual(lost["retry_delay"], 1)
        outcomes = self.events("power-apply", "result")
        self.assertEqual([e["confirmed"] for e in outcomes], [True, False, True])
        self.assertIsNone(outcomes[1]["observed_caps_uw"])
        self.assertEqual(outcomes[1]["errors"], ["power: disconnected"])
        self.assertEqual(outcomes[-1]["reason"], "retry")

    def test_power_diagnostics_failed_correction_reports_backoff_without_poll_spam(self):
        self.controller.power_request(12)
        self.actual = 15
        self.failures = ["busy"]
        self.controller.power_request(12)
        count = self.log.call_count
        self.controller.power_request(12)
        self.assertEqual(self.log.call_count, count)
        self.advance(1)
        self.controller.power_request(12)
        self.assertEqual(self.messages, [{"watts": 12}, {"op": "read"}, {"watts": 12},
                                        {"op": "read"}, {"op": "read"}, {"watts": 12}])
        outcomes = self.events("power-apply", "result")
        self.assertEqual([e["confirmed"] for e in outcomes], [True, False, True])
        self.assertEqual(outcomes[1]["errors"], ["busy"])
        self.assertEqual(outcomes[1]["retry_at"], 101.0)
        self.assertEqual(outcomes[1]["retry_delay"], 1)
        self.assertFalse(outcomes[1]["correction_used"])
        self.assertTrue(outcomes[2]["correction_used"])

    def test_transient_set_retries_same_target_and_clears_error(self):
        self.assertTrue(self.controller.power_request(15)["confirmed"])
        self.failures = ["driver temporarily busy", "driver temporarily busy"]
        self.assertFalse(self.controller.power_request(12)["confirmed"])
        self.controller.power_request(12)
        self.assertEqual(self.sets(), [15, 12])
        self.advance(1)
        self.controller.power_request(12)
        self.advance(1)
        self.controller.power_request(12)
        self.assertEqual(self.sets(), [15, 12, 12])
        self.advance(1)
        self.assertTrue(self.controller.power_request(12)["confirmed"])
        self.assertEqual(self.sets(), [15, 12, 12, 12])
        self.assertEqual(self.controller.errors, [])
        self.assertEqual(self.controller.power_watts, 12)

    def test_reconnect_keeps_backoff(self):
        self.failures = [OSError("disconnected")]
        self.assertIsNone(self.controller.power_request(12))
        self.controller.power_request(12)
        self.assertEqual(self.sets(), [12])
        self.advance(1)
        self.assertTrue(self.controller.power_request(12)["confirmed"])
        self.assertEqual(self.controller.errors, [])

    def test_reconnect_after_correction_invalidates_lease_confirmation(self):
        self.controller.power_request(12)
        self.actual = 15
        self.assertTrue(self.controller.power_request(12)["confirmed"])
        with patch("runtime.request", side_effect=OSError("disconnected")):
            self.assertIsNone(self.controller.power_request(12))
        self.actual = 15  # The disconnected broker lease restores its baseline.
        self.controller.power_request(12)
        self.assertEqual(self.sets(), [12, 12])
        self.advance(1)
        self.assertTrue(self.controller.power_request(12)["confirmed"])
        self.assertEqual(self.sets(), [12, 12, 12])
        self.assertEqual(self.controller.errors, [])
        self.actual = 15
        self.assertFalse(self.controller.power_request(12)["confirmed"])
        self.assertEqual(self.sets(), [12, 12, 12])
        self.assertTrue(any("competing-writer conflict" in e for e in self.controller.errors))

    def test_retry_delay_is_capped_and_target_change_can_apply_immediately(self):
        self.failures = ["busy"] * 9
        self.controller.power_request(12)
        for delay in (1, 2, 4, 8, 16, 30, 30):
            count = len(self.sets())
            self.advance(delay - 0.25)
            self.controller.power_request(12)
            self.assertEqual(len(self.sets()), count)
            self.advance(0.25)
            self.controller.power_request(12)
            self.assertEqual(len(self.sets()), count + 1)
        self.failures = []
        self.assertTrue(self.controller.power_request(10)["confirmed"])
        self.assertEqual(self.sets()[-1], 10)
        self.assertEqual(self.controller.errors, [])

    def test_direct_set_readback_mismatch_retries(self):
        with patch("runtime.request", return_value=caps(15)):
            self.assertFalse(self.controller.power_request(12)["confirmed"])
        self.advance(1)
        self.assertTrue(self.controller.power_request(12)["confirmed"])
        self.assertEqual(self.sets(), [12])

    def test_drift_has_one_successful_correction_not_one_per_good_read(self):
        self.controller.power_request(12)
        self.actual = 15
        self.assertTrue(self.controller.power_request(12)["confirmed"])
        self.controller.power_request(12)
        self.actual = 15
        for _ in range(4):
            self.advance(30)
            self.assertFalse(self.controller.power_request(12)["confirmed"])
        self.assertEqual(self.sets(), [12, 12])
        self.assertTrue(any("TDP readback" in e for e in self.controller.errors))
        self.assertTrue(any("competing-writer conflict" in e for e in self.controller.errors))

    def test_failed_correction_retries_without_poisoning_conflict_budget(self):
        self.controller.power_request(12)
        self.actual = 15
        self.failures = ["driver temporarily busy"]
        self.assertFalse(self.controller.power_request(12)["confirmed"])
        self.controller.power_request(12)
        self.assertEqual(self.sets(), [12, 12])
        self.advance(1)
        self.assertTrue(self.controller.power_request(12)["confirmed"])
        self.assertEqual(self.sets(), [12, 12, 12])
        self.assertEqual(self.controller.errors, [])

    def test_read_can_confirm_self_recovery_before_retry(self):
        self.failures = ["busy"]
        self.controller.power_request(12)
        self.actual = 12
        self.assertTrue(self.controller.power_request(12)["confirmed"])
        self.assertEqual(self.sets(), [12])
        self.assertEqual(self.controller.errors, [])

    def launch(self):
        return self.controller.tick({"app": "123", "display": ":42", "mapping": {"STEAM_GAME_DISPLAY_0": ":42"}})

    def test_resume_releases_conflict_and_backoff(self):
        for transient in (False, True):
            with self.subTest(transient=transient):
                self.launch()
                target = self.sets()[-1]
                self.actual = 15 if target != 15 else 12
                self.controller.power_request(target)
                self.actual = 15 if target != 15 else 12
                if transient:
                    self.failures = ["busy"]
                self.boot += 1
                status = self.controller.tick()
                if transient:
                    self.failures = []
                    self.boot += 1
                    status = self.controller.tick()
                self.assertTrue(status["tdp"]["confirmed"])

    def test_image_operations_retry_independently_through_unchanged_tick(self):
        for failed in ("physical", "virtual", "filter", "scaler"):
            with self.subTest(failed=failed):
                x = FakeX()
                controller = Controller(config(), x)
                controller.read_physical = lambda: None
                controller.power_request = Mock(return_value=caps(12))
                calls = dict.fromkeys(("physical", "virtual", "filter", "scaler"), 0)
                original = x.write

                def operation(name):
                    calls[name] += 1
                    if name == failed and calls[name] == 1:
                        raise OSError("temporary " + name)

                controller.physical = lambda *_: operation("physical")

                def write(name, values):
                    operation({"GAMESCOPE_XWAYLAND_MODE_CONTROL": "virtual", "GAMESCOPE_NEW_SCALING_FILTER": "filter", "GAMESCOPE_NEW_SCALING_SCALER": "scaler"}[name])
                    original(name, values)

                x.write = write
                status = controller.tick({"app": "123", "display": ":42", "mapping": {"STEAM_GAME_DISPLAY_0": ":42"}})
                self.assertTrue(any("temporary " + failed in e for e in status["errors"]))
                self.assertEqual(calls, dict.fromkeys(calls, 1))
                controller.tick()
                self.assertEqual(calls, dict.fromkeys(calls, 1))
                self.advance(1)
                status = controller.tick()
                self.assertFalse(any("temporary" in e for e in status["errors"]))
                self.assertEqual(calls, {name: 2 if name == failed else 1 for name in calls})
                before = calls.copy()
                controller.tick()
                self.assertEqual(calls, before)
                self.assertEqual(controller.power_request.call_count, 4)
                x.writes.append(("GAMESCOPE_NEW_SCALING_SCALER", [0]))
                status = controller.tick()
                self.assertTrue(any("scaler conflict" in e for e in status["errors"]))
                self.assertEqual(calls, before)

    def test_image_recovery_clears_only_its_own_error(self):
        physical = Mock(side_effect=[OSError("physical busy"), None])
        virtual = Mock(side_effect=[OSError("virtual busy"), OSError("virtual busy"), None])
        self.controller.physical = physical
        self.controller.apply_virtual = virtual
        self.launch()
        self.advance(1)
        status = self.controller.tick()
        self.assertFalse(any("physical busy" in e for e in status["errors"]))
        self.assertTrue(any("virtual busy" in e for e in status["errors"]))
        self.advance(2)
        status = self.controller.tick()
        self.assertFalse(any("busy" in e for e in status["errors"]))
        self.assertEqual(physical.call_count, 2)
        self.assertEqual(virtual.call_count, 3)

    def test_successful_physical_submission_does_not_cache_readback_warning(self):
        snapshot = self.x.snapshot()
        self.x.snapshot = lambda: {**snapshot, "screen": "external", "modes": "1920x1080@60",
                                   "connector": {"Connector Name": "HDMI-A-1", "Display Make": "ACME", "Display Model": "Panel"}}
        reads = 0

        def read_physical():
            nonlocal reads
            reads += 1
            if reads == 1:
                self.controller.errors.append("DRM readback unknown: temporary")
                return None
            return [{"name": "HDMI-A-1", "width": 1920, "height": 1080, "hz": 60}]

        self.controller.read_physical = read_physical
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {"GAMESCOPE_MODE_SAVE_FILE": str(Path(directory) / "modes")}):
            status = self.launch()
            self.assertTrue(any("DRM readback unknown" in e for e in status["errors"]))
            self.assertEqual(status["physical_confirmation"], "confirmed")
            writes = self.x.writes.copy()
            self.assertEqual(len(writes), 4)  # Physical nudge, virtual, filter, FIT.
            status = self.controller.tick()
            self.assertFalse(any("DRM readback unknown" in e for e in status["errors"]))
            self.assertEqual(self.x.writes, writes)
            self.assertEqual(reads, 3)  # No repeated physical submission/read.

    def test_gamescopectl_empty_model_and_physical_file_identity(self):
        gamescope = Gamescope.__new__(Gamescope)
        gamescope.connection = SimpleNamespace(pending_events=lambda: False)
        gamescope.xerrors = (RuntimeError,)
        gamescope.legacy_serial = 0
        gamescope.values = lambda name: [1] if name == "GAMESCOPE_DISPLAY_IS_EXTERNAL" else []
        gamescope.text = lambda name: "1920x1080@60" if name == "GAMESCOPE_DISPLAY_MODE_LIST_EXTERNAL" else ""
        for make, model, separator in (("ACME", "Panel", " "), ("ACME", "", " "), ("", "MODEL", " "), ("", "", ""), ("ACME ", " Panel ", " ")):
            with self.subTest(make=make, model=model), patch("runtime.process_state", return_value=(set(), {})), patch("runtime.power_source", return_value="ac"), patch(
                "runtime.subprocess.run", return_value=SimpleNamespace(stdout=f"  - Connector Name: HDMI-A-1\n  - Display Make:{separator}{make}\n  - Display Model:{separator}{model}\n  - Display Flags: 0\n")
            ):
                snapshot = gamescope.snapshot()
                self.assertEqual(snapshot["connector"]["Display Model"], model)
                self.assertEqual(snapshot["connector"]["Display Make"], make)
                description = f"{make} {model}"
                with tempfile.TemporaryDirectory() as directory:
                    path = Path(directory) / "modes"
                    path.write_text(f"OTHER Panel:1280x720@60 1\n{description}:1280x720@60 2\n")
                    with patch.dict(os.environ, {"GAMESCOPE_MODE_SAVE_FILE": str(path)}):
                        self.controller.physical(snapshot, config()["profiles"]["external-ac"])
                    self.assertEqual(path.read_text(), f"OTHER Panel:1280x720@60 1\n{description}:1920x1080@60 2\n")
                    self.assertEqual(self.x.writes[-1][0], "GAMESCOPE_DISPLAY_MODE_NUDGE")
                    self.assertFalse(any("unsafe" in e for e in self.controller.errors))


if __name__ == "__main__":
    unittest.main()
