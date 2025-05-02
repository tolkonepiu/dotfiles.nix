{
  config,
  pkgs,
  lib,
  zdotdir,
  ...
}:

{
  imports = [
    # Import shared configuration
    ../../shared/home-manager
    
    # Include Darwin-specific modules
    ./git.nix
    ./ssh.nix
    ./zsh.nix
    ./direnv.nix
  ];
}
