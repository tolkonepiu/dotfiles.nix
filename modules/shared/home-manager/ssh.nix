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
  };
}
