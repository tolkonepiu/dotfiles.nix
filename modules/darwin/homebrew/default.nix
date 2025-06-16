{
  imports = [
    ./casks.nix
    ./appstore.nix
  ];

  homebrew = {
    enable = true;
    # onActivation.cleanup = "uninstall";
  };
}
