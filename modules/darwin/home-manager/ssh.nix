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
    "/Users/${userConfig.username}/.ssh/config_external"
  ];
}
