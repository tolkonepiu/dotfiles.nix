"""Pure profile selection and Gamescope mode-file policy."""
import copy
import os
from pathlib import Path
import re
import tempfile


def app_id(value):
    return isinstance(value, str) and re.fullmatch(r"[0-9]+", value) is not None and int(value) > 0


def integer(value, low, high):
    if type(value) is not int or not low <= value <= high:
        raise ValueError(f"expected integer in {low}..{high}, got {value!r}")


def dimensions(value, output=False, partial=False):
    keys = {"width", "height", "hz"} if output else {"width", "height"}
    if not isinstance(value, dict) or set(value) - keys or (not partial and set(value) != keys):
        raise ValueError("invalid resolution fields")
    for key, number in value.items():
        integer(number, 1, 1000 if key == "hz" else 16384)


def validate(config):
    if not isinstance(config, dict) or set(config) != {"profiles", "games"} or not isinstance(config["profiles"], dict) or not isinstance(config["games"], dict):
        raise ValueError("expected profiles and games")
    expected = {f"{s}-{p}" for s in ("handheld", "external") for p in ("battery", "ac")}
    if set(config["profiles"]) != expected:
        raise ValueError("expected all four profiles")
    for name, profile in config["profiles"].items():
        if not isinstance(profile, dict) or set(profile) != {"game", "output", "filter", "watts"}:
            raise ValueError("invalid profile fields")
        dimensions(profile["game"])
        dimensions(profile["output"], output=True)
        if name.startswith("handheld-") and profile["output"] != {"width": 1280, "height": 800, "hz": 60}:
            raise ValueError("internal LCD output is fixed at 1280x800@60 (DRM may report 800x1280)")
        integer(profile["watts"], 1, 15)
        if profile["filter"] not in ("linear", "nearest", "fsr"):
            raise ValueError("invalid filter")
    for app, override in config["games"].items():
        if not app_id(app) or not isinstance(override, dict) or set(override) - {"resolution", "power", "filter"}:
            raise ValueError("invalid game override")
        if "filter" in override and override["filter"] not in ("linear", "nearest", "fsr"):
            raise ValueError("invalid filter")
        resolutions = override.get("resolution", {})
        powers = override.get("power", {})
        if not isinstance(resolutions, dict) or not isinstance(powers, dict) or set(resolutions) - {"handheld", "external"} or set(powers) - {"battery", "ac"}:
            raise ValueError("invalid override state")
        for resolution in resolutions.values():
            dimensions(resolution, partial=True)
        for watts in powers.values():
            integer(watts, 1, 15)
    return config


def select(config, screen, power, app=None):
    name = f"{screen}-{power}"
    result = copy.deepcopy(config["profiles"][name])
    override = config["games"].get(app, {})
    result["game"].update(override.get("resolution", {}).get(screen, {}))
    result["watts"] = override.get("power", {}).get(power, result["watts"])
    result["filter"] = override.get("filter", result["filter"])
    if not (result["game"]["width"] < result["output"]["width"] and result["game"]["height"] < result["output"]["height"]):
        result["filter"] = "linear"
    return name, result


def choose_mode(text, wanted):
    modes = {tuple(map(int, m)) for m in re.findall(r"(?<!\S)(\d+)x(\d+)@(\d+)(?!\S)", text)}
    target = (wanted["width"], wanted["height"], wanted["hz"])
    if target in modes:
        return dict(zip(("width", "height", "hz"), target))
    allowed = [m for m in modes if all(0 < a <= b for a, b in zip(m, target))]
    if not allowed:
        return None
    return dict(zip(("width", "height", "hz"), max(allowed, key=lambda m: (m[0] * m[1], m[2], m[0], m[1]))))


def mode_text(text, description, mode):
    if not description or any(c in description for c in ":\n\r"):
        raise ValueError("unsafe display description")
    lines = text.splitlines(keepends=True)
    replacement = f'{description}:{mode["width"]}x{mode["height"]}@{mode["hz"]}'
    found = False
    for index, line in enumerate(lines):
        if line.startswith(description + ":"):
            match = re.fullmatch(r"[^:]+:\d+x\d+@\d+(\s+\d+)?\s*", line)
            if not match:
                raise ValueError("existing selected display mode is malformed")
            lines[index] = replacement + (match.group(1) or "") + "\n"
            found = True
    if not found:
        if lines and not lines[-1].endswith("\n"):
            lines[-1] += "\n"
        lines.append(replacement + "\n")
    return "".join(lines)


def atomic_write(path, text):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(dir=path.parent, prefix="." + path.name)
    try:
        with os.fdopen(fd, "w") as stream:
            stream.write(text)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def power_source(directory="/sys/class/power_supply"):
    known = False
    for supply in Path(directory).iterdir():
        kind = (supply / "type").read_text().strip()
        if kind != "Battery" and (supply / "online").exists():
            online = (supply / "online").read_text().strip()
            if online not in ("0", "1"):
                raise ValueError("invalid power supply online state")
            known = True
            if online == "1":
                return "ac"
    return "battery" if known else None


def server_index(display, environment):
    if display == environment.get("DISPLAY"):
        return 0
    for number in (0, 1):
        if display and display == environment.get(f"STEAM_GAME_DISPLAY_{number}"):
            return number + 1
    raise ValueError("game DISPLAY has no verified Gamescope server mapping")


def display_mapping(mapping, root_display):
    if not isinstance(mapping, dict) or set(mapping) - {"STEAM_GAME_DISPLAY_0", "STEAM_GAME_DISPLAY_1"}:
        raise ValueError("invalid game display mapping")
    for value in mapping.values():
        if not isinstance(value, str) or re.fullmatch(r":\d+(?:\.\d+)?", value) is None:
            raise ValueError("game display mapping must contain local X displays")
    if len(set(mapping.values())) != len(mapping):
        raise ValueError("duplicate game display mapping")
    if "STEAM_GAME_DISPLAY_1" in mapping and ("STEAM_GAME_DISPLAY_0" not in mapping or root_display in mapping.values()):
        raise ValueError("invalid multi-server mapping")
    return {"DISPLAY": root_display, **mapping}


class ActiveGame:
    def __init__(self):
        self.app = None
        self.pending_until = 0

    def launch(self, app, now):
        if not app_id(app):
            raise ValueError("invalid Steam AppID")
        self.app, self.pending_until = app, now + 30

    def observe(self, focused, running, now):
        candidates = [str(a) for a in focused if app_id(str(a)) and str(a) != "769"]
        if self.pending_until:
            if self.app in candidates:
                self.pending_until = 0
            elif now < self.pending_until:
                return self.app
            else:
                self.pending_until = 0
        if candidates:
            self.app = candidates[0]
        elif running is not None and self.app not in running:
            self.app = None
        return self.app
