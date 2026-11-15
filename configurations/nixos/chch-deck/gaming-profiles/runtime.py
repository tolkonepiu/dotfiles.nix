"""Session-scoped Deck controller. No direct DRM modesetting, FPS or clock controls."""
import argparse
import json
import os
from pathlib import Path
import re
import signal
import socket
import subprocess
import sys
import time

from policy import ActiveGame, app_id, atomic_write, choose_mode, display_mapping, mode_text, power_source, select, server_index, validate

ENV_KEYS = {"DISPLAY", "GAMESCOPE_WAYLAND_DISPLAY", "XAUTHORITY", "STEAM_GAME_DISPLAY_0", "STEAM_GAME_DISPLAY_1", "GAMESCOPE_MODE_SAVE_FILE"}
FILTERS = {"linear": 0, "nearest": 1, "fsr": 2}
FAILURES = (OSError, ValueError, RuntimeError, subprocess.SubprocessError)


def log(event, **fields):
    print(json.dumps({"event": event, **fields}), file=sys.stderr, flush=True)


def import_environment(path):
    for line in Path(path).read_text().splitlines():
        key, separator, value = line.partition("=")
        if separator and key in ENV_KEYS and value and not any(c in value for c in "\x00\r\n"):
            os.environ[key] = value


def runtime_dir():
    return Path(os.environ["XDG_RUNTIME_DIR"]) / "deck-gaming-profiles"


def request(stream, message):
    stream.sendall(json.dumps(message).encode() + b"\n")
    data = bytearray()
    while not data.endswith(b"\n"):
        chunk = stream.recv(4096)
        if not chunk:
            raise RuntimeError("control peer disconnected")
        data.extend(chunk)
        if len(data) > 65536:
            raise ValueError("control response too large")
    return json.loads(data)


def process_state(directory="/proc"):
    apps = set()
    mappings = {}
    for path in Path(directory).glob("[0-9]*/environ"):
        try:
            if path.stat().st_uid != os.getuid():
                continue
            environment = {}
            for entry in path.read_bytes().split(b"\0"):
                key, separator, value = entry.partition(b"=")
                if separator and key in (b"SteamAppId", b"DISPLAY", b"STEAM_GAME_DISPLAY_0", b"STEAM_GAME_DISPLAY_1"):
                    environment[key.decode("ascii")] = value.decode("utf-8")
            app = environment.get("SteamAppId")
            if app_id(app):
                apps.add(app)
                if re.fullmatch(r":\d+(?:\.\d+)?", environment.get("DISPLAY", "")):
                    mapping = {key: environment[key] for key in ("STEAM_GAME_DISPLAY_0", "STEAM_GAME_DISPLAY_1") if key in environment}
                    display_mapping(mapping, os.environ["DISPLAY"])
                    mappings[app] = {"display": environment["DISPLAY"], "mapping": mapping}
        except (OSError, UnicodeError):
            # Other users' processes and processes which exit during the scan.
            continue
        except ValueError:
            # Malformed display hints are not a usable candidate.
            continue
    return apps, mappings


def property_text(prop):
    if prop is None:
        return None
    if prop.format == 8:
        raw = bytes(prop.value)
    else:
        # Pinned Gamescope writes FOCUS_DISPLAY bytes using XA_CARDINAL/32.
        raw = b"".join(int(v).to_bytes(4, sys.byteorder) for v in prop.value)
    return raw.split(b"\0", 1)[0].decode("utf-8")


class Gamescope:
    def __init__(self):
        from Xlib import X, Xatom, display, error
        self.X, self.Xatom = X, Xatom
        self.xerrors = (error.XError, error.DisplayConnectionError, error.ConnectionClosedError)
        try:
            self.connection = display.Display(os.environ["DISPLAY"])
        except self.xerrors as exc:
            raise RuntimeError(f"Gamescope X connection: {exc}") from exc
        self.root = self.connection.screen().root
        self.root.change_attributes(event_mask=X.PropertyChangeMask)
        self.legacy_serial = 0

    def prop(self, name):
        try:
            return self.root.get_full_property(self.connection.intern_atom(name), self.X.AnyPropertyType)
        except self.xerrors as exc:
            raise RuntimeError(f"read {name}: {exc}") from exc

    def values(self, name):
        prop = self.prop(name)
        return None if prop is None else list(prop.value)

    def text(self, name):
        return property_text(self.prop(name))

    def write(self, name, values):
        try:
            self.root.change_property(self.connection.intern_atom(name), self.Xatom.CARDINAL, 32, values)
            self.connection.sync()
        except self.xerrors as exc:
            raise RuntimeError(f"write {name}: {exc}") from exc

    def display_properties(self, display_name):
        from Xlib import display
        connection = None
        try:
            connection = display.Display(display_name)
            root = connection.screen().root
            return {name: root.get_full_property(connection.intern_atom(name), self.X.AnyPropertyType)
                    for name in ("GAMESCOPE_PID", "GAMESCOPE_XWAYLAND_SERVER_ID")}
        except (IndexError, *self.xerrors) as exc:
            raise RuntimeError(f"X mapping {display_name}: {exc}") from exc
        finally:
            if connection is not None:
                connection.close()

    def resolve_display(self, display_name, mapping):
        if not isinstance(display_name, str) or re.fullmatch(r":\d+(?:\.\d+)?", display_name) is None:
            raise ValueError("game DISPLAY must be a local X display")
        hints = display_mapping(mapping, os.environ["DISPLAY"])

        def identity(properties):
            values = []
            for name in ("GAMESCOPE_PID", "GAMESCOPE_XWAYLAND_SERVER_ID"):
                prop = properties.get(name)
                if (prop is None or prop.property_type != self.Xatom.CARDINAL or prop.format != 32
                        or len(prop.value) != 1 or type(prop.value[0]) is not int):
                    raise ValueError(f"unverified Gamescope mapping: invalid {name}")
                values.append(prop.value[0])
            pid, index = values
            # Pinned Jovian starts Gamescope with --xwayland-count 2.
            if pid <= 0 or index not in (0, 1):
                raise ValueError("unverified Gamescope mapping: PID/server ID out of range")
            return pid, index

        controller = identity({name: self.prop(name) for name in ("GAMESCOPE_PID", "GAMESCOPE_XWAYLAND_SERVER_ID")})
        candidate = identity(self.display_properties(display_name))
        if controller[1] != 0 or candidate[0] != controller[0]:
            raise ValueError("unverified Gamescope mapping: foreign compositor/root")
        if (mapping or display_name == hints["DISPLAY"]) and server_index(display_name, hints) != candidate[1]:
            raise ValueError("game display mapping contradicts Gamescope server ID")
        return candidate

    def geometry(self, display_name, window=None):
        from Xlib import display
        connection = None
        try:
            connection = display.Display(display_name)
            drawable = connection.create_resource_object("window", window) if window else connection.screen().root
            geometry = drawable.get_geometry()
            return {"width": geometry.width, "height": geometry.height}
        except self.xerrors as exc:
            raise RuntimeError(f"X geometry {display_name}: {exc}") from exc
        finally:
            if connection is not None:
                connection.close()

    def snapshot(self):
        try:
            while self.connection.pending_events():
                event = self.connection.next_event()
                if event.type == self.X.PropertyNotify and event.atom == self.connection.intern_atom("GAMESCOPE_SCALING_FILTER"):
                    self.legacy_serial += 1
        except self.xerrors as exc:
            raise RuntimeError(f"X property events: {exc}") from exc
        external = self.values("GAMESCOPE_DISPLAY_IS_EXTERNAL")
        screen = {0: "handheld", 1: "external"}.get(external[0]) if external and len(external) == 1 else None
        focused = []
        for name in ("GAMESCOPE_FOCUSED_APP_GFX", "GAMESCOPE_FOCUSED_APP"):
            focused.extend(self.values(name) or [])
        focusable = self.values("GAMESCOPE_FOCUSABLE_APPS")
        running, mappings = process_state()
        if focusable is not None:
            running.update(map(str, focusable))
        display_name = self.text("GAMESCOPE_FOCUS_DISPLAY")
        info = {}
        if screen == "external":
            output = subprocess.run(["gamescopectl"], capture_output=True, text=True, check=True, timeout=3).stdout
            for line in output.splitlines():
                match = re.fullmatch(r"[ \t]*- (Connector Name|Display Make|Display Model):[ \t]?(.*)", line)
                if match:
                    info[match[1]] = match[2]
        return {"screen": screen, "power": power_source(), "focused": focused, "running": running,
                "display": display_name, "connector": info,
                "modes": self.text("GAMESCOPE_DISPLAY_MODE_LIST_EXTERNAL") or "", "mappings": mappings,
                "legacy_serial": self.legacy_serial}


class Controller:
    def __init__(self, config, gamescope):
        self.config, self.x = config, gamescope
        self.game = ActiveGame()
        self.game_display = None
        self.game_mapping = {}
        self.virtual_submission = None
        self.last_key = None
        self.candidate = None
        self.power = None
        self.power_watts = None
        self.power_target = None
        self.power_drift_retried = False
        self.power_retry_at = 0
        self.power_retry_delay = 0
        self.power_errors = []
        self.requested = None
        self.errors = []
        self.physical_target = None
        self.effective_filter = None
        self.operations = {}
        self.legacy_serial = 0
        self.suspend_offset = time.clock_gettime(time.CLOCK_BOOTTIME) - time.monotonic()

    def close(self):
        if self.power:
            self.power.close()
            self.power = None

    def power_request(self, watts=None):
        self.errors = [error for error in self.errors if error not in self.power_errors]
        if watts != self.power_target:
            self.power_target = watts
            self.power_watts = None
            self.power_drift_retried = False
            self.power_retry_at = self.power_retry_delay = 0
            self.power_errors = []
        now = time.monotonic()
        attempted = False
        try:
            if self.power is None:
                self.power = socket.socket(socket.AF_UNIX)
                self.power.settimeout(2)
                self.power.connect("/run/deck-gaming-power/control.sock")
            desired = {cap: watts * 1_000_000 for cap in ("power1_cap", "power2_cap")} if watts is not None else None

            def exchange(message):
                result = request(self.power, message)
                if not isinstance(result, dict) or not isinstance(result.get("caps_uw"), dict) or not isinstance(result.get("errors"), list):
                    raise ValueError("invalid power broker response")
                return result

            attempted = desired is not None and watts != self.power_watts and now >= self.power_retry_at
            result = exchange({"watts": watts} if attempted else {"op": "read"})
            correction = False
            if desired is not None and (result["caps_uw"] != desired or result["errors"]) and not attempted and now >= self.power_retry_at and not self.power_drift_retried:
                attempted = True
                correction = self.power_watts == watts
                result = exchange({"watts": watts})
            confirmed = desired is not None and result.get("caps_uw") == desired and not result.get("errors")
            if confirmed:
                self.power_watts = watts
                # A good read must not replenish the budget for fighting another writer.
                self.power_drift_retried |= correction
                self.power_retry_at = self.power_retry_delay = 0
                self.power_errors = []
            elif desired is not None:
                self.power_errors = ["TDP readback mismatch/unknown; requested watts not confirmed", *result["errors"]]
                if result["caps_uw"] != desired and self.power_watts == watts and self.power_drift_retried:
                    self.power_errors.append("TDP competing-writer conflict: corrective write budget exhausted; no further writes until target change or resume")
                if attempted:
                    self.power_retry_delay = min(30, self.power_retry_delay * 2 or 1)
                    self.power_retry_at = now + self.power_retry_delay
            self.errors.extend(self.power_errors)
            return {**result, "confirmed": confirmed}
        except FAILURES as exc:
            self.close()
            self.power_watts = None  # Disconnect releases the broker lease and restores its baseline.
            if now >= self.power_retry_at:
                self.power_retry_delay = min(30, self.power_retry_delay * 2 or 1)
                self.power_retry_at = now + self.power_retry_delay
            self.power_errors = [f"power: {exc}"]
            self.errors.extend(self.power_errors)
            return None

    def physical(self, snapshot, profile):
        self.physical_target = None
        if snapshot["screen"] != "external":
            # Internal panel uses its session-native mode (LCD DRM is rotated).
            self.physical_target = {"connector": "internal", **profile["output"]}
            return
        info = snapshot["connector"]
        if not info.get("Connector Name"):
            raise ValueError("active external connector identity unknown")
        make, model = info.get("Display Make"), info.get("Display Model")
        description = f"{make} {model}" if make is not None and model is not None else "External screen"
        mode = choose_mode(snapshot["modes"], profile["output"])
        if mode is None:
            raise ValueError("no supported physical mode within profile bounds; physical output untouched")
        self.physical_target = {"connector": info["Connector Name"], **mode}
        if mode != profile["output"]:
            self.errors.append(f"physical fallback: {mode}")
        path = os.environ.get("GAMESCOPE_MODE_SAVE_FILE")
        if not path:
            raise ValueError("GAMESCOPE_MODE_SAVE_FILE unavailable")
        path = Path(path)
        old = path.read_text() if path.exists() else ""
        new = mode_text(old, description, mode)
        actual = self.read_physical()
        matches = any(m["name"] == info["Connector Name"] and mode_matches(m, mode) for m in (actual or []))
        if new != old:
            atomic_write(path, new)
        if new != old or not matches:
            self.x.write("GAMESCOPE_DISPLAY_MODE_NUDGE", [int(time.time() * 1000) & 0xffffffff])

    def read_physical(self):
        try:
            result = subprocess.run(["deck-display-info"], capture_output=True, text=True, check=True, timeout=2)
            data = json.loads(result.stdout)
            self.errors.extend(data.get("errors", []))
            return data["connectors"]
        except (KeyError, *FAILURES) as exc:
            self.errors.append(f"DRM readback unknown: {exc}")
            return None

    def apply_virtual(self, profile):
        if self.game_display:
            proof = self.x.resolve_display(self.game_display, self.game_mapping)
            # Dimensions come only from validated Nix config, not launch requests.
            self.x.write("GAMESCOPE_XWAYLAND_MODE_CONTROL", [proof[1], profile["game"]["width"], profile["game"]["height"], 1])
            self.virtual_submission = (self.game_display, profile, proof)
        else:
            raise ValueError("pending-game-resolution: actual game DISPLAY unknown")

    def apply_operation(self, name, operation, target=None):
        state = self.operations.get(name)
        if state is None or state["target"] != target:
            state = {"target": target, "done": False, "retry_at": 0, "delay": 0, "errors": []}
            self.operations[name] = state
        if not state["done"] and time.monotonic() >= state["retry_at"]:
            try:
                operation()
                state["done"] = True
                state["errors"] = []
                state["retry_at"] = state["delay"] = 0
            except FAILURES as exc:
                state["errors"] = [f"{name}: {exc}"]
                state["delay"] = min(30, state["delay"] * 2 or 1)
                state["retry_at"] = time.monotonic() + state["delay"]
        self.errors.extend(state["errors"])

    def apply(self, snapshot, profile):
        self.apply_operation("physical", lambda: self.physical(snapshot, profile))
        self.apply_operation("virtual resolution", lambda: self.apply_virtual(profile))
        output = self.physical_target or profile["output"]
        self.effective_filter = profile["filter"] if profile["game"]["width"] < output["width"] and profile["game"]["height"] < output["height"] else "linear"
        self.apply_operation("scaling filter", lambda: self.x.write("GAMESCOPE_NEW_SCALING_FILTER", [FILTERS[self.effective_filter]]), self.effective_filter)
        self.apply_operation("scaling scaler", lambda: self.x.write("GAMESCOPE_NEW_SCALING_SCALER", [2]))  # FIT, after filter; preserve aspect.

    def tick(self, launch=None):
        self.errors = []
        now = time.time()
        # BOOTTIME includes suspend; MONOTONIC does not, even for a short sleep.
        offset = time.clock_gettime(time.CLOCK_BOOTTIME) - time.monotonic()
        wake = offset - self.suspend_offset > 0.1
        self.suspend_offset = offset
        if wake:
            self.power_watts = None
            self.power_drift_retried = False
            self.power_retry_at = self.power_retry_delay = 0
        snapshot = self.x.snapshot()
        if launch:
            self.x.resolve_display(launch["display"], launch["mapping"])
            self.game.launch(launch["app"], now)
            self.game_display = launch["display"]
            self.game_mapping = launch["mapping"]
        previous_app = self.game.app
        app = self.game.observe(snapshot["focused"], snapshot["running"], now)
        if app != previous_app:
            self.game_display = None
            self.game_mapping = {}
            self.virtual_submission = None
        process_mapping = snapshot.get("mappings", {}).get(app)
        if process_mapping and self.game_display is None:
            self.game_mapping = process_mapping["mapping"]
            self.game_display = process_mapping["display"]
        focused = [str(v) for v in snapshot["focused"]]
        if app and app in focused and snapshot["display"]:
            self.game_display = snapshot["display"]
        if not app:
            self.game_display = None
        screen, power = snapshot["screen"], snapshot["power"]
        if screen is None or power is None:
            self.last_key = None
            self.errors.append("screen or AC state unknown; no writes")
            return self.status(snapshot, app, None, None)
        name, profile = select(self.config, screen, power, app)
        key = json.dumps([screen, power, app, self.game_display, self.game_mapping, snapshot["connector"], snapshot["modes"], profile], sort_keys=True)
        event = key != self.last_key or wake
        if event and (launch or wake or self.candidate == key):
            self.operations.clear()
            self.virtual_submission = None
            self.legacy_serial = snapshot.get("legacy_serial", 0)
            self.last_key = key
            self.requested = profile
        self.candidate = key
        if self.last_key == key:
            self.apply(snapshot, profile)
        if event and self.last_key != key:
            self.errors.append("state debounce pending")
        caps = self.power_request(profile["watts"]) if self.last_key == key else None
        return self.status(snapshot, app, name, profile, caps)

    def status(self, snapshot, app, name, profile, caps=None):
        physical = self.read_physical()
        confirmation = "unknown"
        if physical is not None and self.physical_target:
            target = self.physical_target
            active = [m for m in physical if m["name"] == target["connector"] or (target["connector"] == "internal" and m["name"].startswith(("eDP-", "DSI-")))]
            if active:
                matches = any(mode_matches(m, target) or (target["connector"] == "internal" and mode_matches({**m, "width": m["height"], "height": m["width"]}, target)) for m in active)
                confirmation = "confirmed" if matches else "mismatch"
        if confirmation == "mismatch":
            self.errors.append("physical output readback mismatch; target not confirmed")
        virtual = window = None
        if self.game_display:
            try:
                virtual = self.x.geometry(self.game_display)
                ids = self.x.values("GAMESCOPE_FOCUSED_WINDOW")
                if ids and snapshot["display"] == self.game_display:
                    window = self.x.geometry(self.game_display, ids[0])
            except FAILURES as exc:
                self.errors.append(str(exc))
        feedback = self.x.values("GAMESCOPE_FSR_FEEDBACK")
        filter_value = self.x.values("GAMESCOPE_NEW_SCALING_FILTER")
        scaler_value = self.x.values("GAMESCOPE_NEW_SCALING_SCALER")
        legacy_value = self.x.values("GAMESCOPE_SCALING_FILTER")
        if snapshot.get("legacy_serial", 0) > self.legacy_serial:
            self.errors.append("legacy scaling property changed after profile apply; filter/FIT may be overridden")
        if self.effective_filter and filter_value and filter_value != [FILTERS[self.effective_filter]]:
            self.errors.append("scaling filter conflict: compositor/Steam changed requested filter")
        if self.requested and scaler_value and scaler_value != [2]:
            self.errors.append("scaling scaler conflict: compositor/Steam changed FIT")
        proof = None
        if self.game_display:
            try:
                proof = self.x.resolve_display(self.game_display, self.game_mapping)
            except FAILURES as exc:
                self.errors.append(f"virtual mapping: {exc}")
        submitted = bool(profile and proof is not None and self.virtual_submission == (self.game_display, profile, proof))
        if not submitted and self.operations.get("virtual resolution", {}).get("done"):
            self.operations.pop("virtual resolution")
        pending = bool(profile and (not submitted or virtual != profile["game"]))
        return {"screen": snapshot["screen"], "power": snapshot["power"], "active_app_id": app,
                "selected_profile": name, "requested": profile, "physical_target": self.physical_target,
                "confirmed_drm_physical_modes": physical, "physical_confirmation": confirmation, "virtual_root_size": virtual,
                 "observed_x11_window_size": window, "actual_game_frame": None,
                 "game_display": self.game_display, "pending_game_resolution": pending,
                 "game_mapping": {"source": "gamescope-root-properties", "compositor_pid": proof[0], "server_index": proof[1]} if proof else None,
                 "virtual_resolution_submitted": submitted,
                "fsr_active": bool(feedback[0]) if feedback else None,
                "scaling_filter_confirmation": "fsr-active" if feedback and feedback[0] else "unknown",
                "legacy_scaling_filter": legacy_value,
                "effective_filter": self.effective_filter,
                "tdp": caps, "errors": self.errors.copy()}


def mode_matches(actual, wanted):
    return actual["width"] == wanted["width"] and actual["height"] == wanted["height"] and abs(actual["hz"] - wanted["hz"]) < 1


def daemon(config):
    import_environment(Path(os.environ["XDG_RUNTIME_DIR"]) / "gamescope-environment")
    directory = runtime_dir()
    directory.mkdir(mode=0o700, parents=True, exist_ok=True)
    path = directory / "control.sock"
    if path.exists():
        # A running controller must not have its socket stolen by a second daemon.
        with socket.socket(socket.AF_UNIX) as probe:
            try:
                probe.connect(str(path))
            except ConnectionRefusedError:
                path.unlink()
            else:
                raise RuntimeError("controller already running")
    server = socket.socket(socket.AF_UNIX)
    server.bind(str(path))
    os.chmod(path, 0o600)
    server.listen(4)
    server.settimeout(1)
    controller = None
    stopping = False

    def stop(_signum, _frame):
        nonlocal stopping
        stopping = True

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    previous = None
    try:
        while not stopping:
            client = None
            try:
                try:
                    client, _ = server.accept()
                except socket.timeout:
                    pass
                if controller is None:
                    controller = Controller(config, Gamescope())
                launch = None
                if client:
                    client.settimeout(1)
                    data = bytearray()
                    while not data.endswith(b"\n"):
                        chunk = client.recv(4096)
                        if not chunk or len(data) + len(chunk) > 8192:
                            raise ValueError("invalid launch request")
                        data.extend(chunk)
                    launch = json.loads(data)
                    if not isinstance(launch, dict) or set(launch) != {"app", "display", "mapping"} or not app_id(launch["app"]) or not isinstance(launch["display"], str):
                        raise ValueError("invalid launch request")
                status = controller.tick(launch)
                if launch:
                    deadline = time.monotonic() + 4
                    while status["pending_game_resolution"] and time.monotonic() < deadline:
                        time.sleep(0.1)
                        status = controller.tick()
                    client.sendall(json.dumps({"ok": status["selected_profile"] is not None and not status["pending_game_resolution"], "status": status}).encode() + b"\n")
            except FAILURES as exc:
                status = {"errors": [str(exc)], "screen": None, "requested": None}
                if client:
                    try:
                        client.sendall(json.dumps({"ok": False, "errors": status["errors"]}).encode() + b"\n")
                    except OSError as send_error:
                        log("launch-response-failed", error=str(send_error))
                # Reopen X after compositor failure, releasing the old power lease.
                if controller and isinstance(exc, RuntimeError):
                    controller.close()
                    controller = None
            finally:
                if client:
                    client.close()
            changed = json.dumps(status, sort_keys=True)
            if changed != previous:
                log("state", **status)
                previous = changed
            status.update(pid=os.getpid(), timestamp=time.time(), running=True)
            atomic_write(directory / "status.json", json.dumps(status) + "\n")
    finally:
        if controller:
            controller.close()
        server.close()
        path.unlink(missing_ok=True)
        atomic_write(directory / "status.json", json.dumps({"pid": os.getpid(), "timestamp": time.time(), "running": False}) + "\n")


def launch_game(argv):
    if argv and argv[0] == "--":
        argv = argv[1:]
    if not argv:
        raise ValueError("launch requires original command")
    desktop = os.environ.get("XDG_CURRENT_DESKTOP", "").lower()
    active = "niri" not in desktop and ("gamescope" in desktop or os.environ.get("GAMESCOPE_WAYLAND_DISPLAY"))
    if active:
        try:
            app = os.environ.get("SteamAppId") or os.environ.get("SteamGameId")
            if not app_id(app):
                raise ValueError("numeric SteamAppId/SteamGameId unavailable")
            with socket.socket(socket.AF_UNIX) as stream:
                stream.settimeout(8)
                stream.connect(str(runtime_dir() / "control.sock"))
                mapping = {key: os.environ[key] for key in ("STEAM_GAME_DISPLAY_0", "STEAM_GAME_DISPLAY_1") if key in os.environ}
                response = request(stream, {"app": app, "display": os.environ.get("DISPLAY", ""), "mapping": mapping})
                if not response.get("ok"):
                    raise RuntimeError(f"resolution not confirmed: {response}")
        except (KeyError, *FAILURES) as exc:
            log("LAUNCH-HANDSHAKE-FAILED", error=str(exc), fallback="executing original game unchanged")
    os.execvpe(argv[0], argv, os.environ.copy())


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", required=True)
    parser.add_argument("command", choices=("daemon", "status", "launch"))
    parser.add_argument("argv", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    if args.command == "launch":
        launch_game(args.argv)
    elif args.command == "status":
        try:
            status = json.loads((runtime_dir() / "status.json").read_text())
            alive = False
            try:
                os.kill(status["pid"], 0)
                alive = True
            except (ProcessLookupError, KeyError):
                pass
            status["stale"] = not alive or time.time() - status.get("timestamp", 0) > 10
        except (KeyError, *FAILURES) as exc:
            status = {"running": False, "stale": True, "errors": [str(exc)]}
        print(json.dumps(status, indent=2))
    else:
        daemon(validate(json.loads(Path(args.config).read_text())))


if __name__ == "__main__":
    main()
