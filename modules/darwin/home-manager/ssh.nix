{
  config,
  pkgs,
  lib,
  ...
}:

let
  user = "chchmthrfckr";
in
{
  # Extend with Darwin-specific settings
  programs.ssh.includes = [
    "/Users/${user}/.ssh/config_external"
  ];
}
