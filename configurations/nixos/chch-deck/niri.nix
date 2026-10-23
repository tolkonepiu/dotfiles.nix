{config, ...}: let
  actions = config.lib.niri.actions;
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
    input.touch.map-to-output = "eDP-1";

    binds = with actions; {
      "Mod+Escape".action = close-window;
      "Mod+Left".action = focus-column-left;
      "Mod+Right".action = focus-column-right;
      "Mod+Up".action = focus-workspace-up;
      "Mod+Down".action = focus-workspace-down;
      "Mod+Shift+Left".action = move-column-left;
      "Mod+Shift+Right".action = move-column-right;
      "Mod+Shift+Up".action = move-workspace-up;
      "Mod+Shift+Down".action = move-workspace-down;
    };
  };
}
