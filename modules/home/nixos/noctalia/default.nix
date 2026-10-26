{
  flake,
  lib,
  ...
}: {
  imports = [flake.inputs.noctalia.homeModules.default];

  xdg.dataFile."noctalia/plugins/nixos-update" = {
    source = ./nixos-update;
    recursive = true;
  };

  programs.noctalia = {
    enable = true;

    # Managed by systemd, not by Niri startup.
    systemd.enable = true;
    checkConfig = true;

    settings = {
      plugins.enabled = ["dotfiles/nixos-update"];
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

      bar.default = {
        position = lib.mkDefault "top";
        thickness = lib.mkDefault 34;
        scale = lib.mkDefault 1.0;

        margin_ends = lib.mkDefault 0;
        margin_edge = lib.mkDefault 0;
        padding = lib.mkDefault 8;
        widget_spacing = lib.mkDefault 6;

        auto_hide = lib.mkDefault false;
        smart_auto_hide = lib.mkDefault false;
        reserve_space = lib.mkDefault true;
        layer = lib.mkDefault "top";
        capsule = false;

        start = lib.mkDefault [
          "apps"
        ];

        center = lib.mkDefault [
          "group:workspaces"
        ];

        end = lib.mkDefault [
          "nixos-update"
          "tray"
          "volume"
          "brightness"
          "bluetooth"
          "network"
          "battery"
          "clock"
          "session"
        ];

        capsule_group = [
          {
            id = "workspaces";
            members = ["workspaces"];
          }
        ];
      };

      widget = {
        nixos-update = {
          type = "dotfiles/nixos-update:status";
        };
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

        network.show_label = false;
        clock.format = "{:%H:%M}";
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
