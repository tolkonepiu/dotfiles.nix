{
  lib,
  pkgs,
  ...
}: let
  toggle = pkgs.writeShellApplication {
    name = "deck-keyboard-toggle";
    text = ''
      exec ${pkgs.systemd}/bin/systemctl --user kill \
        --kill-whom=main --signal=RTMIN deck-keyboard.service
    '';
  };
in {
  home.packages = [toggle];

  # Follow only Niri, not Gaming Mode's graphical-session.target.
  # Keep one hidden keyboard per desktop session; never launch another on toggle.
  systemd.user.services.deck-keyboard = {
    Unit = {
      Description = "Steam Deck on-screen keyboard";
      After = ["niri.service"];
      PartOf = ["niri.service"];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      # Explicit US/Russian/symbol cycle; avoid upstream's 120px landscape default.
      ExecStart = lib.concatStringsSep " " [
        "${pkgs.wvkbd}/bin/wvkbd-mobintl --hidden -H 280 -L 280"
        "-l full,cyrillic,special --landscape-layers full,cyrillic,special"
        # Catppuccin Mocha, using wvkbd's built-in color flags (no theme dependency).
        "--bg 1e1e2e --fg 313244 --fg-sp 45475a"
        "--text cdd6f4 --text-sp cdd6f4"
        "--press cba6f7 --press-sp cba6f7 --text-press 1e1e2e --text-press-sp 1e1e2e"
        "--swipe 89b4fa --swipe-sp 89b4fa --text-swipe 1e1e2e --text-swipe-sp 1e1e2e"
      ];
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install.WantedBy = ["niri.service"];
  };

  programs.niri.settings.binds."Mod+K".action.spawn = ["${lib.getExe toggle}"];
}
