{
  lib,
  pkgs,
  userConfig,
  ...
}: {
  programs.firefox.profiles."${userConfig.username}.default".extensions.settings = {
    "FirefoxColor@mozilla.com".settings = {
      firstRunDone = true;

      theme = {
        title = "Catppuccin mocha mauve";

        colors = {
          toolbar = {
            r = 30;
            g = 30;
            b = 46;
          };
          toolbar_text = {
            r = 205;
            g = 214;
            b = 244;
          };
          frame = {
            r = 17;
            g = 17;
            b = 27;
          };
          tab_background_text = {
            r = 205;
            g = 214;
            b = 244;
          };
          toolbar_field = {
            r = 24;
            g = 24;
            b = 37;
          };
          toolbar_field_text = {
            r = 205;
            g = 214;
            b = 244;
          };
          tab_line = {
            r = 203;
            g = 166;
            b = 247;
          };
          popup = {
            r = 30;
            g = 30;
            b = 46;
          };
          popup_text = {
            r = 205;
            g = 214;
            b = 244;
          };
          button_background_active = {
            r = 108;
            g = 112;
            b = 134;
          };
          frame_inactive = {
            r = 17;
            g = 17;
            b = 27;
          };
          icons_attention = {
            r = 203;
            g = 166;
            b = 247;
          };
          icons = {
            r = 203;
            g = 166;
            b = 247;
          };
          ntp_background = {
            r = 17;
            g = 17;
            b = 27;
          };
          ntp_text = {
            r = 205;
            g = 214;
            b = 244;
          };
          popup_border = {
            r = 203;
            g = 166;
            b = 247;
          };
          popup_highlight_text = {
            r = 205;
            g = 214;
            b = 244;
          };
          popup_highlight = {
            r = 108;
            g = 112;
            b = 134;
          };
          sidebar_border = {
            r = 203;
            g = 166;
            b = 247;
          };
          sidebar_highlight_text = {
            r = 17;
            g = 17;
            b = 27;
          };
          sidebar_highlight = {
            r = 203;
            g = 166;
            b = 247;
          };
          sidebar_text = {
            r = 205;
            g = 214;
            b = 244;
          };
          sidebar = {
            r = 30;
            g = 30;
            b = 46;
          };
          tab_background_separator = {
            r = 203;
            g = 166;
            b = 247;
          };
          tab_loading = {
            r = 203;
            g = 166;
            b = 247;
          };
          tab_selected = {
            r = 30;
            g = 30;
            b = 46;
          };
          tab_text = {
            r = 205;
            g = 214;
            b = 244;
          };
          toolbar_bottom_separator = {
            r = 30;
            g = 30;
            b = 46;
          };
          toolbar_field_border_focus = {
            r = 203;
            g = 166;
            b = 247;
          };
          toolbar_field_border = {
            r = 30;
            g = 30;
            b = 46;
          };
          toolbar_field_focus = {
            r = 30;
            g = 30;
            b = 46;
          };
          toolbar_field_highlight_text = {
            r = 30;
            g = 30;
            b = 46;
          };
          toolbar_field_highlight = {
            r = 203;
            g = 166;
            b = 247;
          };
          toolbar_field_separator = {
            r = 203;
            g = 166;
            b = 247;
          };
          toolbar_vertical_separator = {
            r = 203;
            g = 166;
            b = 247;
          };
        };

        images = {
          additional_backgrounds = ["./bg-000.svg"];
          custom_backgrounds = [];
        };
      };

      images = {};
    };
  };
}
