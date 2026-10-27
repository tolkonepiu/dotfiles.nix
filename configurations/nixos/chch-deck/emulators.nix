{
  flake,
  pkgs,
  ...
}: let
  eden = flake.inputs.eden.packages.${pkgs.stdenv.hostPlatform.system}.zen2;

  emulators = [
    pkgs.cemu
    pkgs.xenia-canary
    eden
    pkgs.retroarch
  ];
in {
  # Make emulators available system-wide
  environment.systemPackages = emulators;

  # Expose emulators to Decky Loader
  systemd.services.decky-loader.path = emulators;
}
