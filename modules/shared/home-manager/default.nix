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
    ./bat.nix
    ./direnv.nix
    ./eza.nix
    ./fd.nix
    ./git.nix
    ./ssh.nix
    ./zoxide.nix
    ./zsh.nix
  ];
}
