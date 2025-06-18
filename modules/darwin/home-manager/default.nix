{
  imports = [
    # Import shared configuration
    ../../shared/home-manager

    # Include Darwin-specific modules
    ./firefox.nix
    ./git.nix
    ./ssh.nix
  ];
}
