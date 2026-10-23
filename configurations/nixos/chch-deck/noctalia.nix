{
  programs.noctalia = {
    settings = {
      # Compositor stays at scale 1. Enlarge shell controls independently.
      accessibility.ui_scale = 1.2;
      shell = {
        session = {
          grid = true;
          grid_columns = 2;
          show_shortcuts = false;
          actions = [
            {
              action = "logout";
              label = "Return to Gaming Mode";
              glyph = "device-gamepad";
              # End the native desktop session; Jovian resumes Gaming Mode.
              command = "niri msg action quit --skip-confirmation";
            }
            {
              action = "suspend";
              label = "Sleep";
            }
            {
              action = "reboot";
              label = "Restart";
              countdown_seconds = 5.0;
            }
            {
              action = "shutdown";
              label = "Shut Down";
              countdown_seconds = 5.0;
            }
          ];
        };
      };

      # The shared top bar leaves the bottom edge free for the OSK.
      # Bar scaling is independent of accessibility.ui_scale. 60 * 0.8 gives
      # 48px-high targets; (16px glyph + 2 * 12px padding) * 1.2 = 48px wide.
      bar.default = {
        thickness = 60;
        scale = 1.2;
        layer = "overlay"; # Keep the keyboard button reachable in fullscreen.
        capsule_thickness = 0.8;
        capsule_padding = 12.0;
        start = ["apps" "deck-keyboard"];
      };

      widget = {
        deck-keyboard = {
          type = "custom_button";
          glyph = "keyboard";
          label = "Keyboard";
          tooltip = "Show or hide the on-screen keyboard";
          actions.left = "exec deck-keyboard-toggle";
        };
      };
    };
  };
}
