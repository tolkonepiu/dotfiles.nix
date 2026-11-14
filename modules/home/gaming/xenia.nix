{
  config,
  flake,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
  profile = {
    name = config.me.username;
    xuid = "E000000000000001";
    autoLogin = true;
  };
in {
  imports = [
    flake.inputs.nix-emulators.homeManagerModules.xenia-canary
    flake.inputs.nix-emulators.homeManagerModules.xenia-edge
  ];

  programs = {
    xenia-canary = {
      enable = isLinux && pkgs.stdenv.hostPlatform.isx86_64;
      inherit profile;
    };
    xenia-edge = {
      enable = isLinux && pkgs.stdenv.hostPlatform.isx86_64;
      inherit profile;
    };
  };
}
