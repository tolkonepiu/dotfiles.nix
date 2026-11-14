{
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
in {
  programs.retroarch = {
    enable = isLinux;
    package = pkgs.retroarch-bare.overrideAttrs (old: {
      passthru =
        old.passthru
        // {
          wrapper = args:
            (pkgs.retroarch-bare.wrapper args).overrideAttrs (wrapped: let
              # Keep upstream's generated settings (including assets) and core layout.
              flag = builtins.match "(.*)--add-flags '--appendconfig=([^']+)'(.*)" wrapped.buildCommand;
              appendFlag = "--add-flags '--appendconfig=${builtins.elemAt flag 1}'";
              merge = "retroarch_config=${lib.escapeShellArg (builtins.elemAt flag 1)}; source ${./retroarch-appendconfig.sh}";
            in
              assert lib.assertMsg (flag != null && builtins.length (lib.splitString "--appendconfig=" wrapped.buildCommand) == 2)
              "RetroArch upstream wrapper changed: review appendconfig merging";
              assert lib.assertMsg (wrapped.nativeBuildInputs == [pkgs.makeBinaryWrapper])
              "RetroArch upstream wrapper build inputs changed: review shell wrapper"; {
                nativeBuildInputs = [pkgs.makeWrapper];
                buildCommand = lib.replaceStrings [appendFlag] ["--run ${lib.escapeShellArg merge}"] wrapped.buildCommand;
              });
        };
    });
    settings = {
      input_joypad_driver = "sdl2";
      sort_savefiles_enable = "true";
      sort_savestates_enable = "true";
      savefiles_in_content_dir = "false";
      savestates_in_content_dir = "false";
    };
  };
}
