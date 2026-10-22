{
  lib,
  flake,
  ...
}: {
  nixpkgs = {
    config.allowUnfree = true;
    overlays = lib.attrValues flake.inputs.self.overlays;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # Automatically move old dotfiles out of the way
    backupFileExtension = "dotfiles-backup";
  };
}
