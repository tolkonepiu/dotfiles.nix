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
    # Import shared configuration
    ../../shared/home-manager.nix

    # Include Darwin-specific modules
    ./git.nix
    ./ssh.nix
  ];
}
