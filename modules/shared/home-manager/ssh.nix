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
  programs.ssh = {
    enable = true;
    includes = [
      # Platform-specific paths moved to respective modules
    ];
  };
}
