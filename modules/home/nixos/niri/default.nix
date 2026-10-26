{
  flake,
  lib,
  pkgs,
  ...
}: let
  inherit (flake) inputs;
in {
  imports = [
    ./binds.nix
    inputs.niri.homeModules.stylix
  ];

  programs.niri.settings = {
    hotkey-overlay.skip-at-startup = true;

    input = {
      keyboard.xkb = {
        layout = "us,ru";
        options = "grp:alt_shift_toggle";
      };
      touchpad.tap = true;
    };
    prefer-no-csd = true;

    # Niri starts satellite on demand; no separate service or DISPLAY override.
    xwayland-satellite = {
      enable = true;
      path = lib.getExe flake.inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.xwayland-satellite-stable;
    };
  };

  stylix.targets = {
    niri.enable = true;
  };
}
