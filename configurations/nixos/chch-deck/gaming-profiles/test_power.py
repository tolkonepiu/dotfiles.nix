import json
import os
from pathlib import Path
import pwd
import socket
import subprocess
import sys
import tempfile
import time
import unittest
from unittest.mock import patch

from power import CAPS, Power, lock_caps


class PowerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.hwmon = self.root / "hwmon7"
        self.hwmon.mkdir()
        (self.hwmon / "name").write_text("amdgpu\n")
        self.baseline = {"power1_cap": 12_000_000, "power2_cap": 14_000_000}
        for cap, value in self.baseline.items():
            (self.hwmon / cap).write_text(str(value))
        self.state = self.root / "snapshot.json"
        self.power = Power(self.state, self.root)

    def test_bounds_and_client_paths_rejected(self):
        for watts in (True, False, 0, 16, -1, 2.0, "10", None, 100000):
            with self.subTest(watts=watts):
                self.assertTrue(self.power.request({"watts": watts})["errors"])
        self.assertTrue(self.power.request({"watts": 10, "path": "/tmp/x"})["errors"])
        self.assertEqual(self.power.read(), self.baseline)
        self.assertFalse(self.state.exists())

    def test_units_readback_and_full_restore(self):
        response = self.power.request({"watts": 10})
        self.assertEqual(response, {"caps_uw": dict.fromkeys(CAPS, 10_000_000), "errors": []})
        self.assertEqual(self.power.request({"op": "read"}), response)
        self.assertEqual(json.loads(self.state.read_text()), self.baseline)
        self.assertEqual(os.stat(self.state).st_mode & 0o777, 0o600)
        self.power.apply(8)
        self.assertEqual(self.power.restore(), [])
        self.assertEqual(self.power.read(), self.baseline)
        self.assertFalse(self.state.exists())

    def test_apply_and_restore_events_use_only_existing_reads(self):
        with self.assertLogs("deck-gaming-power", level="INFO") as logs, patch.object(
                self.power, "read", wraps=self.power.read) as read, patch(
                    "power.time.monotonic", return_value=123.5):
            self.assertEqual(self.power.request({"watts": 10})["errors"], [])
            self.assertEqual(read.call_count, 3)
            self.assertEqual(self.power.restore(reason="startup"), [])
            self.assertEqual(read.call_count, 4)
        messages = [record.getMessage() for record in logs.records]
        self.assertTrue(all("monotonic=123.500000" in message for message in messages))
        self.assertIn(f"snapshot-created monotonic=123.500000 caps_uw={self.baseline}", messages)
        for operation, values in (("apply", dict.fromkeys(CAPS, 10_000_000)),
                                  ("restore reason=startup", self.baseline)):
            for cap, value in values.items():
                for event in ("cap-write-intent", "cap-write-success"):
                    before = (f"before_uw={self.baseline[cap]} "
                              if operation == "apply" and event == "cap-write-intent" else "")
                    self.assertIn(f"{event} monotonic=123.500000 operation={operation} "
                                  f"cap={cap} {before}requested_uw={value}", messages)
            self.assertIn(f"cap-readback monotonic=123.500000 operation={operation} "
                          f"caps_uw={values} matched=True", messages)
        self.assertIn("restore-result monotonic=123.500000 reason=startup success=True errors=[]",
                      messages)

    def test_idle_reads_and_noops_do_not_log_or_write(self):
        with self.assertNoLogs("deck-gaming-power", level="INFO"), patch.object(
                self.power, "write", wraps=self.power.write) as write:
            for _ in range(3):
                self.assertEqual(self.power.request({"op": "read"})["errors"], [])
                self.assertEqual(self.power.restore(), [])
            write.assert_not_called()
        self.power.apply(10)
        with self.assertNoLogs("deck-gaming-power", level="INFO"), patch.object(
                self.power, "write", wraps=self.power.write) as write:
            for _ in range(3):
                self.assertEqual(self.power.request({"op": "read"})["errors"], [])
                self.assertEqual(self.power.request({"watts": 10})["errors"], [])
            write.assert_not_called()

    def test_partial_write_rolls_back_original_snapshot(self):
        self.power.apply(10)
        write = self.power.write

        def fail_second(cap, value):
            if cap == "power2_cap" and value == 8_000_000:
                raise OSError("injected failure")
            write(cap, value)

        with patch.object(self.power, "write", side_effect=fail_second), self.assertLogs(
                "deck-gaming-power", level="INFO") as logs:
            self.assertTrue(self.power.request({"watts": 8})["errors"])
        messages = "\n".join(record.getMessage() for record in logs.records)
        self.assertIn("operation=apply cap=power2_cap before_uw=10000000 requested_uw=8000000", messages)
        self.assertFalse(any("cap-write-success" in record.getMessage()
                             and "operation=apply cap=power2_cap" in record.getMessage()
                             for record in logs.records))
        self.assertIn(f"operation=restore reason=rollback caps_uw={self.baseline} matched=True", messages)
        self.assertIn("reason=rollback success=True errors=[]", messages)
        self.assertEqual(self.power.read(), self.baseline)
        self.assertFalse(self.state.exists())

    def test_stale_recovery_before_new_snapshot(self):
        self.power.apply(7)
        restarted = Power(self.state, self.root)
        self.assertEqual(restarted.restore(), [])
        restarted.apply(9)
        self.assertEqual(json.loads(self.state.read_text()), self.baseline)
        self.assertEqual(restarted.restore(), [])
        self.assertEqual(restarted.read(), self.baseline)

    def test_repeated_noop_and_reapply_drift(self):
        self.power.apply(10)
        with patch.object(self.power, "write", wraps=self.power.write) as write:
            self.power.apply(10)
            write.assert_not_called()
            (self.hwmon / "power2_cap").write_text("15000000")
            self.power.apply(10)
            write.assert_called_once_with("power2_cap", 10_000_000)

    def test_hwmon_renumbering_preserves_lease_snapshot(self):
        self.power.apply(10)
        self.hwmon.rename(self.root / "hwmon11")
        self.assertEqual(self.power.request({"op": "read"}), {
            "caps_uw": dict.fromkeys(CAPS, 10_000_000), "errors": []})
        self.assertEqual(self.power.request({"watts": 8}), {
            "caps_uw": dict.fromkeys(CAPS, 8_000_000), "errors": []})
        self.assertEqual(json.loads(self.state.read_text()), self.baseline)
        self.assertEqual(self.power.restore(), [])
        self.assertEqual(self.power.read(), self.baseline)

    def test_missing_device_retains_snapshot_until_recovery(self):
        self.power.apply(10)
        offline = self.root / "offline"
        offline.mkdir()
        self.hwmon.rename(offline / "hwmon7")
        self.assertTrue(self.power.request({"watts": 8})["errors"])
        self.assertTrue(self.power.request({"op": "read"})["errors"])
        self.assertTrue(self.power.restore())
        self.assertEqual(json.loads(self.state.read_text()), self.baseline)
        (offline / "hwmon7").rename(self.root / "hwmon11")
        self.assertEqual(self.power.restore(), [])
        self.assertEqual(self.power.read(), self.baseline)
        self.assertFalse(self.state.exists())

    def test_driver_limits(self):
        (self.hwmon / "power1_cap_min").write_text("3000000")
        (self.hwmon / "power2_cap_max").write_text("12000000")
        for watts in (1, 13):
            self.assertTrue(self.power.request({"watts": watts})["errors"])
        self.assertEqual(self.power.request({"watts": 3})["errors"], [])

    def test_valid_bounds(self):
        for watts in (1, 15):
            self.assertEqual(self.power.request({"watts": watts}), {
                "caps_uw": dict.fromkeys(CAPS, watts * 1_000_000), "errors": []})

    def test_rollback_errors_returned_and_snapshot_retained(self):
        self.power.apply(10)
        with patch.object(self.power, "write", side_effect=OSError("unavailable")):
            response = self.power.request({"watts": 8})
        self.assertIn("rollback failed", response["errors"][0])
        self.assertTrue(self.state.exists())
        self.assertEqual(self.power.restore(), [])

    def test_mismatch_not_confirmed_and_failed_restore_retained(self):
        with patch.object(self.power, "write"), self.assertLogs(
                "deck-gaming-power", level="INFO") as logs:
            self.assertTrue(self.power.request({"watts": 10})["errors"])
        self.assertTrue(any(f"operation=apply caps_uw={self.baseline} matched=False"
                            in record.getMessage() for record in logs.records))
        self.power.apply(10)
        with patch.object(self.power, "write"):
            self.assertTrue(self.power.restore())
        self.assertTrue(self.state.exists())
        self.assertEqual(self.power.restore(), [])

    def test_device_must_be_unambiguous_and_complete(self):
        (self.hwmon / "power2_cap").unlink()
        with self.assertRaises(ValueError):
            Power(self.state, self.root)
        (self.hwmon / "power2_cap").write_text("15000000")
        other = self.root / "hwmon9"
        other.mkdir()
        (other / "name").write_text("amdgpu")
        with self.assertRaises(ValueError):
            Power(self.state, self.root)

    def test_startup_locks_caps_without_restoring_permissions(self):
        for cap in CAPS:
            (self.hwmon / cap).chmod(0o666)
        with patch("power.os.chown") as chown:
            lock_caps(self.root)
            self.assertEqual(chown.call_count, 2)
            for cap in CAPS:
                chown.assert_any_call(self.hwmon / cap, 0, 0)
        self.power.apply(10)
        self.assertEqual(self.power.restore(), [])
        for cap in CAPS:
            self.assertEqual((self.hwmon / cap).stat().st_mode & 0o777, 0o644)

    def test_socket_controller_lifecycle(self):
        timeout = 30
        path = self.root / "control.sock"
        log = tempfile.TemporaryFile(mode="w+")
        self.addCleanup(log.close)
        child = subprocess.Popen([
            sys.executable, "-c",
            "import sys, logging; logging.basicConfig(level=logging.INFO); "
            "from power import Power, daemon; "
            "daemon(Power(sys.argv[1], sys.argv[2]), sys.argv[3], sys.argv[4])",
            str(self.state), str(self.root), str(path), pwd.getpwuid(os.getuid()).pw_name,
        ], cwd=Path(__file__).parent, stderr=log)
        try:
            with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as controller:
                controller.settimeout(timeout)
                deadline = time.monotonic() + timeout
                while True:
                    try:
                        controller.connect(str(path))
                        break
                    except (FileNotFoundError, ConnectionRefusedError):
                        self.assertIsNone(child.poll(), "broker exited before accepting")
                        self.assertLess(time.monotonic(), deadline, "broker startup timed out")
                        time.sleep(0.01)
                self.assertEqual(path.stat().st_mode & 0o777, 0o600)
                self.assertEqual(path.stat().st_uid, os.getuid())
                with controller.makefile("rb") as responses:
                    controller.sendall(b'{"watts":10}\n{"op":"read"}\nnot-json\n')
                    expected = {"caps_uw": dict.fromkeys(CAPS, 10_000_000), "errors": []}
                    self.assertEqual(json.loads(responses.readline()), expected)
                    self.assertEqual(json.loads(responses.readline()), expected)
                    self.assertTrue(json.loads(responses.readline())["errors"])
                    self.assertTrue(self.state.exists())
                    controller.shutdown(socket.SHUT_WR)
                    # The broker restores caps before closing the accepted connection.
                    self.assertEqual(responses.read(1), b"")
            self.assertFalse(self.state.exists())
            self.assertEqual(self.power.read(), self.baseline)
            with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as controller:
                controller.settimeout(timeout)
                controller.connect(str(path))
                controller.sendall(b"x" * 4097)
                self.assertEqual(controller.recv(1), b"")
            with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as controller:
                controller.settimeout(timeout)
                controller.connect(str(path))
                with controller.makefile("rb") as responses:
                    controller.sendall(b'{"op":"read"}\n')
                    self.assertEqual(json.loads(responses.readline()), {
                        "caps_uw": self.baseline, "errors": []})
                    child.terminate()
                    self.assertEqual(responses.read(1), b"")
                self.assertEqual(child.wait(timeout=timeout), 0)
            self.assertFalse(path.exists())
            log.seek(0)
            messages = log.read()
            self.assertRegex(messages, rf"lease-accepted monotonic=\d+\.\d+ lease_id=1 peer_pid={os.getpid()} peer_uid={os.getuid()}")
            self.assertRegex(messages, r"lease-closed monotonic=\d+\.\d+ lease_id=1 reason=EOF")
            self.assertRegex(messages, r"lease-closed monotonic=\d+\.\d+ lease_id=2 reason=error")
            self.assertRegex(messages, r"lease-closed monotonic=\d+\.\d+ lease_id=3 reason=shutdown")
            self.assertEqual(messages.count("lease-accepted"), 3)
            self.assertIn("reason=disconnect success=True errors=[]", messages)
            self.assertEqual(messages.count("snapshot-created"), 1)
            self.assertEqual(messages.count("cap-write-intent"), 4)
        finally:
            if child.poll() is None:
                child.kill()
            child.wait(timeout=timeout)


if __name__ == "__main__":
    unittest.main()
