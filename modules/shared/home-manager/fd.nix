{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.fd = {
    enable = true;
    hidden = true;
    ignores = [ ".git/" ];
  };
}
