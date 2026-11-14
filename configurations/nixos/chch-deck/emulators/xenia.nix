{
  flake,
  pkgs,
  ...
}: let
  emulators = flake.inputs.nix-emulators.packages.${pkgs.stdenv.hostPlatform.system};
  xeniaPackages = [emulators.xenia-canary-git emulators.xenia-edge-git];
in {
  environment.systemPackages = xeniaPackages;
  jovian.decky-loader.extraPackages = xeniaPackages;
}
