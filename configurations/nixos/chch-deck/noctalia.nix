{flake, ...}: {
  imports = [flake.inputs.noctalia.homeModules.default];

  # Current noctalia-dev/noctalia uses programs.noctalia and TOML;
  # programs.noctalia-shell/settings.json belongs to the older QML shell.
  programs.noctalia = {
    enable = true;
    # niri.nix scopes the upstream unit to niri.service, not Gaming Mode.
    # Do not also spawn Noctalia in compositor startup.
    systemd.enable = true;
    checkConfig = true;

    settings = {
      theme = {
        source = "builtin";
        builtin = "Catppuccin"; # The built-in dark palette is Mocha (#1e1e2e).
        mode = "dark";
      };

      # Compositor stays at scale 1. Enlarge shell controls independently.
      accessibility.ui_scale = 1.2;
      shell = {
        panel.transparency_mode = "solid";
        launcher = {
          default_view = "all";
          app_grid = true;
          compact = false;
          width = 760;
        };
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

      # One full-width top bar leaves the bottom edge free for the OSK.
      # Bar scaling is independent of accessibility.ui_scale. 60 * 0.8 gives
      # 48px-high targets; (16px glyph + 2 * 12px padding) * 1.2 = 48px wide.
      # No centered section: upstream clips start/end at the centered widget,
      # even when the other half of the bar has free space.
      bar.default = {
        position = "top";
        thickness = 60;
        scale = 1.2;
        margin_ends = 0;
        margin_edge = 0;
        padding = 8;
        widget_spacing = 6;
        auto_hide = false;
        smart_auto_hide = false;
        reserve_space = true;
        layer = "overlay"; # Keep the keyboard button reachable in fullscreen.
        capsule = true;
        capsule_thickness = 0.8;
        capsule_padding = 12.0;
        start = ["deck-launcher" "deck-keyboard" "deck-session"];
        center = [];
        # Network, Bluetooth, volume and brightness live in Controls, keeping
        # generous space for the three essential labeled buttons at 1280px.
        end = ["clock" "tray" "notifications" "battery" "deck-controls"];
      };

      widget = {
        deck-launcher = {
          type = "custom_button";
          glyph = "apps";
          label = "Apps";
          tooltip = "Open applications";
          actions.left = "panel-toggle launcher";
        };
        deck-keyboard = {
          type = "custom_button";
          glyph = "keyboard";
          label = "Keyboard";
          tooltip = "Show or hide the on-screen keyboard";
          actions.left = "exec deck-keyboard-toggle";
        };
        deck-session = {
          type = "custom_button";
          glyph = "device-gamepad";
          label = "Gaming";
          tooltip = "Return to Gaming Mode, sleep, restart or shut down";
          actions.left = "panel-toggle session";
        };
        deck-controls = {
          type = "custom_button";
          glyph = "adjustments-horizontal";
          label = "Controls";
          tooltip = "Wi-Fi, Bluetooth, sound, brightness and power";
          actions.left = "panel-toggle control-center";
        };
        tray = {
          # Bound the bar width even when many applications have tray icons.
          drawer = true;
          drawer_columns = 3;
          drawer_item_size = 32;
        };
        clock.format = "{:%H:%M}";
      };

      control_center = {
        show_shortcut_labels = true;
        show_session_button = true;
        shortcuts = map (type: {inherit type;}) ["wifi" "bluetooth" "audio" "notification" "power_profile" "session"];
      };
    };
  };
}
