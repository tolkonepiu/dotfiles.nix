{
  flake,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    pkgs.cemu
    pkgs.xenia-canary
    flake.inputs.eden.packages.${pkgs.stdenv.hostPlatform.system}.zen2
    pkgs.retroarch
  ];
}
