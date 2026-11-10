{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../../common
    ./auto-upgrade.nix
    ./openssh.nix
  ];

  # Override nixos-unified's legacy string default with the NixOS list type.
  nix.settings.experimental-features = ["nix-command" "flakes"];

  services.fstrim.enable = true;
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  programs.zsh.enable = true;
  users.users = lib.genAttrs config.myusers (_: {
    extraGroups = ["wheel" "networkmanager"];
    shell = pkgs.zsh;
    # Set passwords during installation; no credentials are stored in this repo.
  });
}
