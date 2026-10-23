{
  flake,
  lib,
  ...
}: {
  imports = [flake.inputs.noctalia.homeModules.default];

  # Current noctalia-dev/noctalia uses programs.noctalia and TOML;
  # programs.noctalia-shell/settings.json belongs to the older QML shell.
  programs.noctalia = {
    enable = true;
    # The upstream unit follows wayland.systemd.target.
    # Do not also spawn Noctalia in compositor startup.
    systemd.enable = true;
    checkConfig = true;

    settings = {
      theme = {
        source = "builtin";
        builtin = "Catppuccin"; # The built-in dark palette is Mocha (#1e1e2e).
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

      # One full-width top bar, with host overrides for touch sizing.
      # No centered section: upstream clips start/end at the centered widget,
      # even when the other half of the bar has free space.
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
        capsule = lib.mkDefault true;
        capsule_thickness = lib.mkDefault 0.76;
        capsule_padding = lib.mkDefault 6.0;
        start = lib.mkDefault ["apps"];
        center = lib.mkDefault [];
        # The built-in power button opens Session; it does not shut down directly.
        end = lib.mkDefault ["clock" "tray" "notifications" "battery" "session"];
      };

      widget = {
        apps = {
          type = "custom_button";
          glyph = "apps";
          label = "Apps";
          tooltip = "Open applications";
          actions.left = "panel-toggle launcher";
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
