{
  nix = {
    # We use the determinate-nix installer for macOS which manages Nix for us,
    # so we don't want nix-darwin to do it.
    enable = false;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # Automatically move old dotfiles out of the way
    backupFileExtension = "dotfiles-backup";
  };

  system.stateVersion = 6;
}
