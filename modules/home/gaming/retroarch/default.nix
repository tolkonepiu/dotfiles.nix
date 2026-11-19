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
              appendFlag = ''--add-flags "--appendconfig=$out/share/retroarch/declarative-retroarch.cfg"'';
              merge = "retroarch_config=$out/share/retroarch/declarative-retroarch.cfg; source ${./retroarch-appendconfig.sh}";
            in
              assert lib.assertMsg (lib.hasInfix appendFlag wrapped.buildCommand && builtins.length (lib.splitString "--appendconfig=" wrapped.buildCommand) == 2)
              "RetroArch upstream wrapper changed: review appendconfig merging";
              assert lib.assertMsg (wrapped.nativeBuildInputs == [pkgs.makeBinaryWrapper])
              "RetroArch upstream wrapper build inputs changed: review shell wrapper"; {
                nativeBuildInputs = [pkgs.makeWrapper];
                # Expand $out at build time, before makeWrapper writes the runtime command.
                buildCommand = lib.replaceStrings [appendFlag] [''--run "${merge}"''] wrapped.buildCommand;
              });
        };
    });
    settings = {
      video_driver = "vulkan";
      input_joypad_driver = "sdl2";
      sort_savestates_enable = "true";
      savefiles_in_content_dir = "false";
      savestates_in_content_dir = "false";
    };
  };
}
