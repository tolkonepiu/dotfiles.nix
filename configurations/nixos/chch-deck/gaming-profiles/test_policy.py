import copy
import json
import os
from pathlib import Path
import tempfile
import unittest

from policy import ActiveGame, choose_mode, mode_text, power_source, select, server_index, validate


def config():
    return {"profiles": {f"{screen}-{power}": {
        "game": {"width": 1600 if screen == "external" and power == "ac" else 1280,
                 "height": (900 if power == "ac" else 720) if screen == "external" else 800},
        "output": {"width": 1920 if screen == "external" else 1280, "height": 1080 if screen == "external" else 800, "hz": 60},
        "filter": "fsr" if screen == "external" else "linear", "watts": 12 if power == "battery" else 15,
    } for screen in ("handheld", "external") for power in ("battery", "ac")}, "games": {}}


class PolicyTests(unittest.TestCase):
    def test_four_transitions_partial_override_and_removal(self):
        settings = config()
        settings["games"]["123"] = {"resolution": {"external": {"width": 1366}}, "power": {"ac": 13}, "filter": "nearest"}
        validate(settings)
        before = copy.deepcopy(settings)
        for screen in ("handheld", "external"):
            for power in ("battery", "ac"):
                name, result = select(settings, screen, power, "123")
                self.assertEqual(name, f"{screen}-{power}")
                self.assertEqual(result["watts"], 13 if power == "ac" else 12)
                self.assertEqual(result["game"]["height"], settings["profiles"][name]["game"]["height"])
                if screen == "external":
                    self.assertEqual(result["game"]["width"], 1366)
                self.assertEqual(select(settings, screen, power)[1]["watts"], settings["profiles"][name]["watts"])
        self.assertEqual(settings, before)

    def test_native_filter_is_linear(self):
        self.assertEqual(select(config(), "handheld", "battery")[1]["filter"], "linear")

    def test_letterboxed_one_to_one_is_not_upscale(self):
        settings = config()
        settings["games"]["123"] = {"resolution": {"handheld": {"height": 720}, "external": {"width": 1920, "height": 900}}}
        self.assertEqual(select(settings, "handheld", "battery", "123")[1]["filter"], "linear")
        self.assertEqual(select(settings, "external", "battery", "123")[1]["filter"], "linear")

    def test_internal_output_is_fixed(self):
        settings = config()
        settings["profiles"]["handheld-ac"]["output"]["hz"] = 90
        with self.assertRaises(ValueError):
            validate(settings)

    def test_validation(self):
        for value in (0, 16, True, 1.2):
            settings = config()
            settings["profiles"]["handheld-ac"]["watts"] = value
            with self.assertRaises(ValueError):
                validate(settings)
        for app in ("abc", "0", "12;touch x"):
            settings = config()
            settings["games"][app] = {}
            with self.assertRaises(ValueError):
                validate(settings)

    def test_ac_online_even_full_battery(self):
        with tempfile.TemporaryDirectory() as directory:
            for name, entries in {"BAT0": {"type": "Battery", "status": "Full"}, "AC": {"type": "Mains", "online": "1"}}.items():
                supply = Path(directory) / name
                supply.mkdir()
                for key, value in entries.items():
                    (supply / key).write_text(value)
            self.assertEqual(power_source(directory), "ac")
            (Path(directory) / "AC/online").write_text("0")
            self.assertEqual(power_source(directory), "battery")

    def test_mode_fallback_cannot_choose_4k(self):
        wanted = {"width": 1920, "height": 1080, "hz": 60}
        self.assertEqual(choose_mode("3840x2160@60 1920x1080@60", wanted), wanted)
        self.assertEqual(choose_mode("3840x2160@60 1280x720@60 1920x1080@120", wanted)["width"], 1280)
        self.assertIsNone(choose_mode("3840x2160@60 1920x1080@120", wanted))

    def test_mode_file_rgb_and_unrelated_lines(self):
        text = "Other:2560x1440@60 2\nMAKE MODEL:1920x1080@120 1\n# unchanged\n"
        mode = {"width": 1280, "height": 720, "hz": 60}
        result = mode_text(text, "MAKE MODEL", mode)
        self.assertEqual(result, "Other:2560x1440@60 2\nMAKE MODEL:1280x720@60 1\n# unchanged\n")
        self.assertEqual(mode_text(result, "MAKE MODEL", mode), result)

    def test_mapping_not_x_display_number(self):
        env = {"DISPLAY": ":7", "STEAM_GAME_DISPLAY_0": ":42", "STEAM_GAME_DISPLAY_1": ":99"}
        self.assertEqual(server_index(":42", env), 1)
        self.assertEqual(server_index(":99", env), 2)
        self.assertEqual(server_index(":7", {"DISPLAY": ":7", "STEAM_GAME_DISPLAY_0": ":7"}), 0)
        with self.assertRaises(ValueError):
            server_index(":1", env)

    def test_launch_pending_overlay_and_exit(self):
        game = ActiveGame()
        game.launch("123", 100)
        self.assertEqual(game.observe([769], set(), 101), "123")
        self.assertEqual(game.observe([123], {"123"}, 102), "123")
        self.assertEqual(game.pending_until, 0)
        self.assertEqual(game.observe([769], {"123"}, 103), "123")
        self.assertIsNone(game.observe([769], set(), 104))
        game.launch("123", 200)
        self.assertIsNone(game.observe([769], set(), 231))

    @unittest.skipUnless(os.environ.get("DECK_PROFILES_TEST_CONFIG"), "generated Nix config not provided")
    def test_generated_config(self):
        validate(json.loads(Path(os.environ["DECK_PROFILES_TEST_CONFIG"]).read_text()))


if __name__ == "__main__":
    unittest.main()
