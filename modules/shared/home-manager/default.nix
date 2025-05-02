{
  config,
  pkgs,
  lib,
  zdotdir,
  ...
}:

{
  imports = [
    ./git.nix
    ./zsh.nix
    ./ssh.nix
    ./direnv.nix
  ];
}
