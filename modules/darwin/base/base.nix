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
    overlays = [
      (final: prev: {
        pythonPackagesExtensions =
          prev.pythonPackagesExtensions
          ++ [
            (python-final: python-prev: {
              aioboto3 = python-prev.aioboto3.overrideAttrs (_: {
                doCheck = false;
              });
            })
          ];
      })
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # Automatically move old dotfiles out of the way
    backupFileExtension = "dotfiles-backup";
  };

  system.stateVersion = 6;
}
