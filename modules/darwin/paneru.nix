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
        auto_center = true;

        animation_speed = 15;
        preset_column_widths = [0.50 0.60 0.70 0.80 0.90 1.00];
        window_resize_cycle = false;
      };
      padding = {
        top = 12;
        bottom = 12;
      };
      bindings = {
        # Vim-like focus: h/j/k/l
        window_focus_west = "ctrl + alt - h";
        window_focus_south = "ctrl + alt - j";
        window_focus_north = "ctrl + alt - k";
        window_focus_east = "ctrl + alt - l";

        # Move/swap focused window: same directions + shift
        window_swap_west = "ctrl + alt + shift - h";
        window_swap_south = "ctrl + alt + shift - j";
        window_swap_north = "ctrl + alt + shift - k";
        window_swap_east = "ctrl + alt + shift - l";

        # Strip edges
        # a / ; are home-row-ish: left edge / right edge
        window_focus_first = "ctrl + alt - a";
        window_focus_last = "ctrl + alt - ;";
        window_swap_first = "ctrl + alt + shift - a";
        window_swap_last = "ctrl + alt + shift - ;";

        # Virtual workspaces / rows
        # Matches niri's default idea: U = down, I = up
        window_virtual_south = "ctrl + alt - u";
        window_virtual_north = "ctrl + alt - i";
        window_virtualmove_south = "ctrl + alt + shift - u";
        window_virtualmove_north = "ctrl + alt + shift - i";

        # Direct virtual workspace access
        window_virtualnum_1 = "ctrl + alt - 1";
        window_virtualnum_2 = "ctrl + alt - 2";
        window_virtualnum_3 = "ctrl + alt - 3";
        window_virtualnum_4 = "ctrl + alt - 4";
        window_virtualnum_5 = "ctrl + alt - 5";
        window_virtualnum_6 = "ctrl + alt - 6";
        window_virtualnum_7 = "ctrl + alt - 7";
        window_virtualnum_8 = "ctrl + alt - 8";
        window_virtualnum_9 = "ctrl + alt - 9";

        # Move window to numbered virtual workspace and follow it
        window_virtualmovenum_1 = "ctrl + alt + shift - 1";
        window_virtualmovenum_2 = "ctrl + alt + shift - 2";
        window_virtualmovenum_3 = "ctrl + alt + shift - 3";
        window_virtualmovenum_4 = "ctrl + alt + shift - 4";
        window_virtualmovenum_5 = "ctrl + alt + shift - 5";
        window_virtualmovenum_6 = "ctrl + alt + shift - 6";
        window_virtualmovenum_7 = "ctrl + alt + shift - 7";
        window_virtualmovenum_8 = "ctrl + alt + shift - 8";
        window_virtualmovenum_9 = "ctrl + alt + shift - 9";

        # Layout actions
        window_resize = "ctrl + alt - r";
        window_shrink = "ctrl + alt + shift - r";

        window_fullwidth = "ctrl + alt - f";
        window_center = "ctrl + alt - c";
        window_manage = "ctrl + alt - v";

        # Stacking
        window_stack = "ctrl + alt - [";
        window_unstack = "ctrl + alt - ]";
        window_equalize = "ctrl + alt - e";

        # Multi-display
        window_nextdisplay = "ctrl + alt - n";
        window_nextdisplaysend = "ctrl + alt + shift - n";
        mouse_nextdisplay = "ctrl + alt + shift - m";

        # Snap current window back into viewport
        window_snap = "ctrl + alt - s";

        # Quit Paneru
        quit = "ctrl + alt + shift - q";
      };
      swipe = {
        deceleration = 0.4;
        sensitivity = 0.4;
        continuous = false;
        gesture = {
          fingers_count = 3;
          direction = "Natural";
          vertical = true;
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
