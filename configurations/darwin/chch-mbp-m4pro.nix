# See /modules/darwin/* for actual settings
# This file is just *top-level* configuration.
{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    self.darwinModules.default
  ];

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    overlays = [
      self.overlays.ghostty-bin
    ];
  };

  networking.hostName = "chch-mbp-m4pro";

  system.primaryUser = "chchmthrfckr";
}
