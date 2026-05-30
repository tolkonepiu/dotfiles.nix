{
  lib,
  flake,
  ...
}: let
  inherit (flake.inputs) self;
in {
  determinateNix = {
    # Let Determinate Nix manage Nix configuration.
    # This also disables nix-darwin's built-in Nix management.
    enable = true;

    # Disable Determinate Nix crash reporting
    determinateNixd.telemetry.sentry.endpoint = null;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = lib.attrValues self.overlays;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # Automatically move old dotfiles out of the way
    backupFileExtension = "dotfiles-backup";
  };

  system.stateVersion = 6;
}
