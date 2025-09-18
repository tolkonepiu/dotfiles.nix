{
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    package = lib.mkIf isDarwin pkgs.ghostty-bin;
    settings = {
      font-family = "MesloLGS NF";
      font-size = 18;
      fullscreen = true;
      mouse-hide-while-typing = true;
    };
  };
}
