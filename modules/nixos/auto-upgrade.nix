{
  config,
  lib,
  ...
}: {
  system.autoUpgrade = {
    enable = lib.mkDefault true;
    flake = lib.mkDefault "github:tolkonepiu/dotfiles.nix/main#${config.networking.hostName}";
    operation = lib.mkDefault "boot";
    upgrade = lib.mkDefault false;
    allowReboot = lib.mkDefault false;
    dates = lib.mkDefault "04:40";
    randomizedDelaySec = lib.mkDefault "5min";
    persistent = lib.mkDefault true;
    flags = ["--no-update-lock-file" "--no-write-lock-file"];
  };
}
