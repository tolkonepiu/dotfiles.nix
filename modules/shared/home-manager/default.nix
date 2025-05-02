{
  config,
  pkgs,
  lib,
  zdotdir,
  userConfig,
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
