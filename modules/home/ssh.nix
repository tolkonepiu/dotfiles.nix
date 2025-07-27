{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  # Create the Secretive SSH configuration (Only for macOS)
  home.file.".ssh/config_secretive" = lib.mkIf isDarwin {
    text = ''
      Host *
        IdentityAgent ${config.home.homeDirectory}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
    '';
  };

  programs.ssh = {
    enable = true;

    includes = [
      (lib.mkIf isDarwin "${config.home.homeDirectory}/.ssh/config_secretive")
      "${config.home.homeDirectory}/.ssh/config_external"
    ];
  };
}
