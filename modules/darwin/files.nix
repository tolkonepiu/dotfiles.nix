{
  userConfig,
  config,
  pkgs,
  lib,
  ...
}:

{
  # Create the Secretive SSH configuration (only for Apple Silicon)
  ".ssh/config_secretive" = lib.mkIf pkgs.stdenv.hostPlatform.isAarch64 {
    text = ''
      Host *
        IdentityAgent /Users/${userConfig.username}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
    '';
  };
}
