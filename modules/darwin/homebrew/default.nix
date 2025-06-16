{
  imports = [
    ./casks.nix
    ./appstore.nix
  ];

  homebrew = {
    enable = true;
    global.autoUpdate = false;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # cleanup = "zap";
    };
  };
}
