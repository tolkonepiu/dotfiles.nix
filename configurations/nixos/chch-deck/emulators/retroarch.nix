{
  config,
  lib,
  ...
}: let
  user = config.jovian.steam.user;
  paths = import ./paths.nix;
  retroarch = config.home-manager.users.${user}.programs.retroarch;
in {
  home-manager.users.${user} = {
    programs.retroarch = {
      enable = true;
      settings = {
        input_joypad_driver = "sdl2";
        system_directory = paths.bios;
        savefile_directory = paths.saves;
        savestate_directory = paths.states;
        sort_savefiles_enable = "true";
        sort_savestates_enable = "true";
        savefiles_in_content_dir = "false";
        savestates_in_content_dir = "false";
      };
    };
    # HM configures the wrapper but does not create the config file Ludo discovers.
    xdg.configFile."retroarch/retroarch.cfg".text =
      lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: ''${name} = "${value}"'') retroarch.settings) + "\n";
  };
  jovian.decky-loader.extraPackages = [retroarch.finalPackage];
}
