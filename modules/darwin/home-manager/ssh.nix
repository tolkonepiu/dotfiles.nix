{
  userConfig,
  pkgs,
  lib,
  ...
}:

{
  # Create the Secretive SSH configuration (only for Apple Silicon)
  home.file.".ssh/config_secretive" = lib.mkIf pkgs.stdenv.hostPlatform.isAarch64 {
    text = ''
      Host *
        IdentityAgent /Users/${userConfig.username}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
    '';
  };

  # Extend with Darwin-specific settings
  programs.ssh.includes = [
    (lib.mkIf pkgs.stdenv.hostPlatform.isAarch64 "/Users/${userConfig.username}/.ssh/config_secretive")
    "/Users/${userConfig.username}/.ssh/config_external"
  ];
}
