{config, ...}: let
  inherit (import ./paths.nix) bios;
  user = config.jovian.steam.user;
  retroarch = config.home-manager.users.${user}.programs.retroarch;
in {
  home-manager.users.${user}.programs.retroarch.settings = {
    system_directory = bios;
    video_fullscreen = "true";
  };

  jovian.decky-loader.extraPackages = [retroarch.finalPackage];
}
