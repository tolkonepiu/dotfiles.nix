{flake, ...}: _: prev: {
  inherit (flake.inputs.ghostty-bin-nixpkgs.legacyPackages.${prev.system}) ghostty-bin;
}
