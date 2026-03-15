{flake, ...}: _: prev: {
  inherit (flake.inputs.devenv-nixpkgs.legacyPackages.${prev.system}) devenv;
}
