{userConfig, ...}: {
  nix = {
    # We use the determinate-nix installer which manages Nix for us,
    # so we don't want nix-darwin to do it.
    enable = false;
  };

  environment.etc."nix/nix.custom.conf".text = ''
    trusted-users = root @admin ${userConfig.username}
    extra-substituters = https://nix-community.cachix.org
    extra-trusted-public-keys = nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
  '';

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
}
