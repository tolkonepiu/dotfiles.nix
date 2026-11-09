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

  home-manager.users.chch.imports = [
    self.homeModules.desktop
    self.homeModules.desktop-nixos
    ./home.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "chch-deck";
  services.openssh.enable = true;
  system.stateVersion = "26.11";
}
