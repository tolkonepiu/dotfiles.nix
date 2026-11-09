# Top-level flake glue to get our configuration working
{
  inputs,
  self,
  lib,
  ...
}: {
  imports = [
    inputs.nixos-unified.flakeModules.default
    inputs.nixos-unified.flakeModules.autoWire
  ];
  perSystem = {
    self',
    system,
    pkgs,
    ...
  }: let
    nixpkgs =
      if lib.hasSuffix "-darwin" system
      then inputs.nixpkgs-darwin
      else inputs.nixpkgs;
  in {
    nixos-unified.primary-inputs = ["nixpkgs" "nixpkgs-darwin" "home-manager" "nix-darwin"];

    _module.args.pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = builtins.attrValues self.overlays;
    };

    checks.nixpkgs-source = assert toString pkgs.path == nixpkgs.outPath;
    assert pkgs.config.allowUnfree;
    assert builtins.length pkgs.overlays == builtins.length (builtins.attrValues self.overlays);
      pkgs.runCommand "nixpkgs-source" {} "touch $out";

    # Enables 'nix run' to activate.
    packages.default = self'.packages.activate;
  };
}
