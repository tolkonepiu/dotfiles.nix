{
  flake,
  pkgs,
  ...
}: {
  imports = [flake.inputs.niri.nixosModules.niri];

  programs.niri.enable = true;
  programs.niri.package = flake.inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
}
