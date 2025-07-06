{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in 
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  programs.spicetify = {
    enable = true;

    theme = lib.mkForce spicePkgs.themes.catppuccin;
    colorScheme = lib.mkForce "mocha";

    enabledExtensions = with spicePkgs.extensions; [
      adblock
      shuffle
      hidePodcasts
      volumePercentage
    ];
  };
}
