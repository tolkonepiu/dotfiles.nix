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
    ../../shared/home-manager

    # Include Darwin-specific modules
    ./git.nix
    ./ssh.nix
  ];
}
