{flake, ...}: let
  inherit (flake) inputs;
in {
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "mauve";
    atuin.enable = true;
    bat.enable = true;
    bottom.enable = true;
    delta.enable = true;
    eza.enable = true;
  };
}
