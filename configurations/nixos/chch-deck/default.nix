{flake, ...}: let
  inherit (flake.inputs) self;
in {
  imports = [
    self.nixosModules.base
    self.nixosModules.desktop
    ./boot.nix
    ./disko.nix
    ./steamdeck.nix
  ];

  home-manager.sharedModules = [
    self.homeModules.desktop
    self.homeModules.desktop-nixos
    self.homeModules.gaming
    ./home.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "chch-deck";
  networking.networkmanager.enable = true;
  system.stateVersion = "26.11";
}
