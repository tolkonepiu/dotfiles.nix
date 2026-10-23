{
  config,
  flake,
  lib,
  pkgs,
  ...
}: let
  actions = config.lib.niri.actions;
  noctalia = lib.getExe config.programs.noctalia.package;
in {
  # Gaming Mode also uses graphical-session.target. Desktop-only services must
  # follow niri itself, not every graphical session started by Jovian.
  wayland.systemd.target = "niri.service";

  programs.niri.settings = {
    outputs."eDP-1" = {
      scale = 1;
      # Matches `niri msg output eDP-1 transform normal`.
      transform.rotation = 0;
    };
    input = {
      keyboard.xkb = {
        layout = "us,ru";
        options = "grp:alt_shift_toggle";
      };
      touch.map-to-output = "eDP-1";
      touchpad.tap = true;
    };

    # Niri starts satellite on demand; no separate service or DISPLAY override.
    xwayland-satellite = {
      enable = true;
      path = lib.getExe flake.inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.xwayland-satellite-stable;
    };

    binds = with actions; {
      "Mod+Return".action = spawn (lib.getExe config.programs.alacritty.package);
      "Mod+Space".action = spawn noctalia "msg" "panel-toggle" "launcher";
      "Mod+Comma".action = spawn noctalia "msg" "settings-toggle";
      "Mod+Q".action = close-window;
      "Mod+O".action = toggle-overview;
      "Mod+Left".action = focus-column-left;
      "Mod+Right".action = focus-column-right;
      "Mod+Up".action = focus-window-up;
      "Mod+Down".action = focus-window-down;
      "Mod+Shift+Left".action = move-column-left;
      "Mod+Shift+Right".action = move-column-right;
      "Mod+Shift+Up".action = move-window-up;
      "Mod+Shift+Down".action = move-window-down;
      "Mod+Page_Up".action = focus-workspace-up;
      "Mod+Page_Down".action = focus-workspace-down;
      "Mod+Shift+Page_Up".action = move-column-to-workspace-up;
      "Mod+Shift+Page_Down".action = move-column-to-workspace-down;
      "Mod+F".action = maximize-column;
      "Mod+Shift+F".action = fullscreen-window;
      "Mod+V".action = toggle-window-floating;
      "Mod+R".action = switch-preset-column-width;
      "Mod+Shift+E".action = quit;
      "XF86AudioRaiseVolume".action = spawn noctalia "msg" "volume-up";
      "XF86AudioLowerVolume".action = spawn noctalia "msg" "volume-down";
      "XF86AudioMute".action = spawn noctalia "msg" "volume-mute";
      "XF86MonBrightnessUp".action = spawn noctalia "msg" "brightness-up";
      "XF86MonBrightnessDown".action = spawn noctalia "msg" "brightness-down";
    };
  };
}
