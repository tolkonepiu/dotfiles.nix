{
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
  };
}
