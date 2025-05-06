{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}:

{
  # Extend with Darwin-specific settings
  programs.ssh.includes = [
    (lib.mkIf pkgs.stdenv.hostPlatform.isAarch64 "/Users/${userConfig.username}/.ssh/config_secretive")
    "/Users/${userConfig.username}/.ssh/config_external"
  ];
}
