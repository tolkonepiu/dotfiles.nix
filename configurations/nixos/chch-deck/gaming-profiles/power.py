"""Root-only, connection-scoped Steam Deck power-cap broker."""

import argparse
import json
import logging
import os
from pathlib import Path
import pwd
import signal
import socket
import stat
import struct
import tempfile
import time


CAPS = ("power1_cap", "power2_cap")
LOG = logging.getLogger("deck-gaming-power")


def lock_caps(hwmon=Path("/sys/class/hwmon")):
    # Activation may leave permissions from the previously enabled Jovian rule.
    for name in Path(hwmon).glob("*/name"):
        if name.read_text().strip() == "amdgpu":
            for cap in CAPS:
                path = name.parent / cap
                if path.exists():
                    os.chown(path, 0, 0)
                    path.chmod(0o644)


class Power:
    def __init__(self, state, hwmon=Path("/sys/class/hwmon")):
        self.state = Path(state)
        self.hwmon = Path(hwmon)
        self.discover()

    def discover(self):
        devices = []
        for entry in self.hwmon.glob("*/name"):
            if entry.read_text().strip() == "amdgpu":
                devices.append(entry.parent)
        if len(devices) != 1:
            raise ValueError("expected exactly one amdgpu hwmon device")
        self.device = devices[0]
        if not all((self.device / cap).is_file() for cap in CAPS):
            raise ValueError("amdgpu must expose both power1_cap and power2_cap")

    def read(self):
        self.discover()
        return {cap: int((self.device / cap).read_text().strip()) for cap in CAPS}

    def write(self, cap, value):
        (self.device / cap).write_text(str(value))

    def save(self, values):
        fd, name = tempfile.mkstemp(prefix=".snapshot-", dir=self.state.parent)
        try:
            with os.fdopen(fd, "w") as stream:
                json.dump(values, stream)
                stream.flush()
                os.fsync(stream.fileno())
            os.replace(name, self.state)
            LOG.info("snapshot-created monotonic=%.6f caps_uw=%s", time.monotonic(), values)
        finally:
            if os.path.exists(name):
                os.unlink(name)

    def restore(self, reason="manual"):
        if not self.state.exists():
            return []
        LOG.info("restore-start monotonic=%.6f reason=%s", time.monotonic(), reason)
        try:
            self.discover()
            info = self.state.lstat()
            if (not stat.S_ISREG(info.st_mode) or info.st_uid != os.geteuid()
                    or info.st_mode & 0o077):
                raise ValueError("snapshot must be a root-only regular file")
            values = json.loads(self.state.read_text())
            if (not isinstance(values, dict) or set(values) != set(CAPS)
                    or any(type(v) is not int or v < 0 for v in values.values())):
                raise ValueError("invalid snapshot")
        except (OSError, ValueError) as error:
            LOG.error("snapshot restore: %s", error)
            LOG.info("restore-result monotonic=%.6f reason=%s success=False errors=%s",
                     time.monotonic(), reason, [str(error)])
            return [str(error)]
        errors = []
        for cap, value in values.items():
            try:
                LOG.info("cap-write-intent monotonic=%.6f operation=restore reason=%s cap=%s requested_uw=%s",
                         time.monotonic(), reason, cap, value)
                self.write(cap, value)
                LOG.info("cap-write-success monotonic=%.6f operation=restore reason=%s cap=%s requested_uw=%s",
                         time.monotonic(), reason, cap, value)
            except OSError as error:
                errors.append(f"restore {cap}: {error}")
        try:
            readback = self.read()
            LOG.info("cap-readback monotonic=%.6f operation=restore reason=%s caps_uw=%s matched=%s",
                     time.monotonic(), reason, readback, readback == values)
            if readback != values:
                errors.append("restore readback mismatch")
        except (OSError, ValueError) as error:
            errors.append(f"restore readback: {error}")
        if not errors:
            try:
                self.state.unlink()
            except OSError as error:
                errors.append(f"remove snapshot: {error}")
        for error in errors:
            LOG.error("%s", error)
        LOG.info("restore-result monotonic=%.6f reason=%s success=%s errors=%s",
                 time.monotonic(), reason, not errors, errors)
        return errors

    def apply(self, watts):
        if type(watts) is not int or not 1 <= watts <= 15:
            raise ValueError("watts must be an integer from 1 through 15")
        self.discover()
        value = watts * 1_000_000
        for cap in CAPS:
            for suffix, valid in (("min", lambda limit: value >= limit),
                                  ("max", lambda limit: value <= limit)):
                limit = self.device / f"{cap}_{suffix}"
                if limit.exists() and not valid(int(limit.read_text().strip())):
                    raise ValueError(f"{cap}: requested watts outside driver {suffix}")
        before = self.read()
        desired = dict.fromkeys(CAPS, value)
        if before == desired:
            return
        if not self.state.exists():
            self.save(before)
        try:
            for cap in CAPS:
                if before[cap] != value:
                    LOG.info("cap-write-intent monotonic=%.6f operation=apply cap=%s before_uw=%s requested_uw=%s",
                             time.monotonic(), cap, before[cap], value)
                    self.write(cap, value)
                    LOG.info("cap-write-success monotonic=%.6f operation=apply cap=%s requested_uw=%s",
                             time.monotonic(), cap, value)
            readback = self.read()
            LOG.info("cap-readback monotonic=%.6f operation=apply caps_uw=%s matched=%s",
                     time.monotonic(), readback, readback == desired)
            if readback != desired:
                raise ValueError("power-cap readback mismatch")
        except (OSError, ValueError) as error:
            errors = self.restore(reason="rollback")
            if errors:
                raise ValueError(f"{error}; rollback failed: {'; '.join(errors)}") from error
            raise

    def request(self, request):
        errors = []
        try:
            if request == {"op": "read"}:
                pass
            elif isinstance(request, dict) and set(request) == {"watts"}:
                self.apply(request["watts"])
            else:
                raise ValueError('expected {"watts": integer} or {"op": "read"}')
        except (OSError, ValueError) as error:
            errors.append(str(error))
        try:
            caps = self.read()
            if (not errors and isinstance(request, dict) and "watts" in request
                    and caps != dict.fromkeys(CAPS, request["watts"] * 1_000_000)):
                errors.append("power-cap readback mismatch")
        except (OSError, ValueError) as error:
            caps = {}
            errors.append(f"readback: {error}")
        for error in errors:
            LOG.error("%s", error)
        return {"caps_uw": caps, "errors": errors}


def daemon(power, path, user):
    uid = pwd.getpwnam(user).pw_uid
    if power.restore(reason="startup"):
        raise RuntimeError("stale snapshot could not be restored; refusing service")
    stopping = False
    lease_id = 0

    def stop(_signum, _frame):
        nonlocal stopping
        stopping = True

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    path = Path(path)
    path.unlink(missing_ok=True)
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as server:
            # No window with a world-accessible socket before chmod/chown.
            old_umask = os.umask(0o177)
            try:
                server.bind(str(path))
            finally:
                os.umask(old_umask)
            path.chmod(0o600)
            os.chown(path, uid, -1)
            server.listen(1)
            server.settimeout(0.5)
            while not stopping:
                try:
                    connection, _ = server.accept()
                except socket.timeout:
                    continue
                with connection:
                    peer = connection.getsockopt(socket.SOL_SOCKET, socket.SO_PEERCRED, 12)
                    peer_pid, peer_uid, _ = struct.unpack("3i", peer)
                    if peer_uid != uid:
                        LOG.error("rejected unauthorized power broker peer")
                        continue
                    lease_id += 1
                    LOG.info("lease-accepted monotonic=%.6f lease_id=%s peer_pid=%s peer_uid=%s",
                             time.monotonic(), lease_id, peer_pid, peer_uid)
                    connection.settimeout(0.5)
                    pending = b""
                    close_reason = "shutdown"
                    try:
                        while not stopping:
                            try:
                                data = connection.recv(4096)
                            except socket.timeout:
                                continue
                            if not data:
                                close_reason = "EOF"
                                break
                            pending += data
                            if len(pending) > 4096:
                                raise ValueError("request exceeds 4096 bytes")
                            while b"\n" in pending and not stopping:
                                line, pending = pending.split(b"\n", 1)
                                try:
                                    response = power.request(json.loads(line))
                                except (ValueError, UnicodeDecodeError) as error:
                                    response = {"caps_uw": {}, "errors": [str(error)]}
                                connection.sendall(json.dumps(response).encode() + b"\n")
                    except (OSError, ValueError) as error:
                        close_reason = "error"
                        LOG.error("controller connection: %s", error)
                    finally:
                        LOG.info("lease-closed monotonic=%.6f lease_id=%s reason=%s",
                                 time.monotonic(), lease_id, close_reason)
                        if power.restore(reason="shutdown" if stopping else "disconnect"):
                            raise RuntimeError("disconnect restore failed; refusing service")
    finally:
        power.restore(reason="shutdown")
        path.unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    serve = sub.add_parser("daemon")
    serve.add_argument("--socket", required=True)
    serve.add_argument("--state", required=True)
    serve.add_argument("--user", required=True)
    restore = sub.add_parser("restore")
    restore.add_argument("--state", required=True)
    args = parser.parse_args()
    logging.basicConfig(level=logging.INFO)
    if os.geteuid() != 0:
        parser.error("power broker must run as root")
    # ExecStopPost must succeed even if no write occurred and hardware disappeared.
    if args.command == "restore" and not Path(args.state).exists():
        return 0
    try:
        if args.command == "daemon":
            lock_caps()
        power = Power(args.state)
        if args.command == "restore":
            return int(bool(power.restore(reason="CLI-cleanup")))
        daemon(power, args.socket, args.user)
    except (OSError, ValueError, RuntimeError) as error:
        LOG.error("%s", error)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
