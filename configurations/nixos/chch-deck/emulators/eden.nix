{
  flake,
  pkgs,
  ...
}: let
  eden = flake.inputs.eden.packages.${pkgs.stdenv.hostPlatform.system}.zen2;
in {
  environment.systemPackages = [eden];
  jovian.decky-loader.extraPackages = [eden];
}
