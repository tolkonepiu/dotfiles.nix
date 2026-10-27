{
  lib,
  pkgs,
  ...
}: let
  paths = import ./paths.nix;
  settings = {
    input_joypad_driver = "sdl2";
    system_directory = paths.bios;
    savefile_directory = paths.saves;
    savestate_directory = paths.states;
    sort_savefiles_enable = true;
    sort_savestates_enable = true;
    savefiles_in_content_dir = false;
    savestates_in_content_dir = false;
  };
  retroarch = pkgs.wrapRetroArch {
    # The wrapper interpolates values; booleans must be "true"/"false", not "1"/"".
    settings = lib.mapAttrs (_: value:
      if builtins.isBool value
      then lib.boolToString value
      else value)
    settings;
  };
in {
  environment.systemPackages = [retroarch];
  jovian.decky-loader.extraPackages = [retroarch];
}
