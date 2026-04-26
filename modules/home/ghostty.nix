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
      confirm-close-surface = false;
      font-family = "IosevkaTerm Nerd Font Mono";
      font-size = 16.5;
      fullscreen = true;
      mouse-hide-while-typing = true;
      mouse-scroll-multiplier = 10;
      shell-integration-features = "no-cursor,no-ssh-terminfo,ssh-env,sudo,title";
    };
  };
}
