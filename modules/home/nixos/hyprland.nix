{
  wayland.windowManager.hyprland = {
    enable = true;
    settings.monitor = [
      {
        output = "";
        scale = 1;
      }
    ];
    settings.config = {
      ecosystem.no_update_news = true;
      input = {
        kb_layout = "us,ru";
        kb_options = "grp:alt_shift_toggle";
      };
    };
  };
}
