{
  config,
  lib,
  flake,
  pkgs,
  ...
}: {
  imports = [
    ../common
    ./auto-upgrade.nix
    ./niri.nix
    flake.inputs.chaotic.nixosModules.default
    flake.inputs.disko.nixosModules.disko
  ];

  # Override nixos-unified's legacy string default with the NixOS list type.
  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.networkmanager.enable = true;
  # Battery status for desktop sessions.
  services.upower.enable = true;
  programs = {
    zsh.enable = true;
  };
  users.users = lib.genAttrs config.myusers (_: {
    extraGroups = ["wheel" "networkmanager"];
    shell = pkgs.zsh;
    # Set passwords during installation; no credentials are stored in this repo.
  });
}
