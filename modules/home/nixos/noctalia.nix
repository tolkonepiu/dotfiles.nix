{
  flake,
  lib,
  ...
}: {
  imports = [flake.inputs.noctalia.homeModules.default];

  programs.noctalia = {
    enable = true;

    # Managed by systemd, not by Niri startup.
    systemd.enable = true;
    checkConfig = true;

    settings = {
      # Catppuccin Mocha.
      theme = {
        source = "builtin";
        builtin = "Catppuccin";
        mode = "dark";
      };

      shell = {
        panel.transparency_mode = "solid";

        launcher = {
          default_view = "all";
          app_grid = true;
          compact = false;
          width = 760;
        };
      };

      # Floating top bar with separate capsule groups.
      bar.default = {
        position = lib.mkDefault "top";
        thickness = lib.mkDefault 42;
        scale = lib.mkDefault 1.0;

        margin_ends = lib.mkDefault 8;
        margin_edge = lib.mkDefault 6;
        padding = lib.mkDefault 8;
        widget_spacing = lib.mkDefault 6;

        auto_hide = lib.mkDefault false;
        smart_auto_hide = lib.mkDefault false;
        reserve_space = lib.mkDefault true;
        layer = lib.mkDefault "top";

        # Transparent bar; only capsule groups have backgrounds.
        background_opacity = 0.0;
        shadow = false;
        capsule = false;

        start = lib.mkDefault [
          "group:launcher"
        ];

        center = lib.mkDefault [
          "group:workspaces"
        ];

        end = lib.mkDefault [
          "group:system"
          "group:connectivity"
          "group:clock"
        ];

        # Individual Catppuccin Mocha Crust capsules.
        capsule_group = [
          {
            id = "launcher";
            members = ["apps"];
            fill = "#11111b";
            padding = 10.0;
            radius = 20.0;
            opacity = 0.96;
          }
          {
            id = "workspaces";
            members = ["workspaces"];
            fill = "#11111b";
            padding = 10.0;
            radius = 20.0;
            opacity = 0.96;
          }
          {
            id = "system";
            members = [
              "session"
              "tray"
              "volume"
              "brightness"
            ];
            fill = "#11111b";
            padding = 8.0;
            radius = 20.0;
            opacity = 0.96;
            widget_spacing = 6;
          }
          {
            id = "connectivity";
            members = [
              "bluetooth"
              "network"
              "battery"
            ];
            fill = "#11111b";
            padding = 8.0;
            radius = 20.0;
            opacity = 0.96;
            widget_spacing = 6;
          }
          {
            id = "clock";
            members = ["clock"];
            fill = "#11111b";
            padding = 10.0;
            radius = 20.0;
            opacity = 0.96;
          }
        ];
      };

      widget = {
        # Application launcher.
        apps = {
          type = "custom_button";
          glyph = "apps";
          label = "Apps";
          tooltip = "Open applications";
          actions.left = "panel-toggle launcher";
        };

        # Built-in workspace indicators.
        workspaces = {
          type = "workspaces";
        };

        # Session opens the power menu.
        session = {
          type = "session";
        };

        # Compact system tray with overflow drawer.
        tray = {
          drawer = true;
          drawer_columns = 3;
          drawer_item_size = 32;
        };

        clock.format = "{:%a %d, %H:%M}";
      };

      control_center = {
        show_shortcut_labels = true;
        show_session_button = true;

        shortcuts = map (type: {inherit type;}) [
          "wifi"
          "bluetooth"
          "audio"
          "notification"
          "power_profile"
          "session"
        ];
      };
    };
  };
}
