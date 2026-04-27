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
      (_: prev: {
        pythonPackagesExtensions =
          prev.pythonPackagesExtensions
          ++ [
            (_: python-prev: {
              aioboto3 = python-prev.aioboto3.overrideAttrs (_: {
                doInstallCheck = false;
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
