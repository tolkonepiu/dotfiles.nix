# See /modules/darwin/* for actual settings
# This file is just *top-level* configuration.
{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    self.darwinModules.base
    self.darwinModules.desktop
  ];

  home-manager.users.chch.imports = [
    self.homeModules.dev
    self.homeModules.darwin
    self.homeModules.desktop
  ];

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
  };

  networking.hostName = "chch-mbp-m4pro";

  system.primaryUser = "chch";
}
