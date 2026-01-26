{flake, ...}: let
  inherit (flake) inputs;
in {
  imports = [
    inputs.determinate.darwinModules.default
    ./base.nix
    ./nix-settings.nix
  ];
}
