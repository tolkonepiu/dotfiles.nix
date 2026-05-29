{flake, ...}: let
  inherit (flake) inputs;
in {
  imports = [
    inputs.paneru.darwinModules.paneru
  ];

  services.paneru = {
    enable = true;

    settings = {
      options = {
        focus_follows_mouse = true;
        mouse_follows_focus = true;
        animation_speed = 15;
        preset_column_widths = [0.50 0.60 0.70 0.80 0.90 1.00];
        window_resize_cycle = false;
      };
      padding = {
        top = 12;
        bottom = 12;
      };
      bindings = {
        window_focus_west = "ctrl + alt - ,";
        window_focus_east = "ctrl + alt - .";

        window_swap_west = "cmd + ctrl + alt - ,";
        window_swap_east = "cmd + ctrl + alt - .";

        window_resize = "ctrl + alt - ]";
        window_shrink = "ctrl + alt - [";

        window_fullwidth = "ctrl + alt - '";
        window_manage = "ctrl + alt - ;";

        quit = "ctrl + alt - q";
      };
      swipe = {
        deceleration = 0.4;
        sensitivity = 0.4;
        continuous = false;
        gesture = {
          fingers_count = 3;
          direction = "Natural";
        };
      };
      decorations = {
        active = {
          border = {
            enabled = true;
            color = "#cba6f7";
            width = 2.0;
            radius = 12.0;
          };
        };
        inactive = {
          dim = {
            opacity = 0.3;
            color = "#181825";
          };
        };
      };
      windows = {
        all = {
          title = ".*";
          horizontal_padding = 6;
          vertical_padding = 0;
          width = 0.5;
        };
      };
    };
  };
}
