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
    ./eza.nix
    ./git.nix
    ./zsh.nix
    ./ssh.nix
    ./direnv.nix
  ];
}
