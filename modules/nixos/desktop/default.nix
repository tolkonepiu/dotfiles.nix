{
  imports = [./niri.nix];

  # Battery status for desktop sessions.
  services.upower.enable = true;
}
