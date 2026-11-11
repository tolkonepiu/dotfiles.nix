{
  programs.vesktop = {
    enable = true;
    vencord = {
      # Work around the white screen on macOS with Vesktop 1.6.8.
      # https://github.com/NixOS/nixpkgs/issues/584740
      useSystem = false;
      mutableSettings = true;
      settings = {};
    };

    settings = {
      discordBranch = "stable";
      tray = false;
      minimizeToTray = false;
      autoStartMinimized = false;
      openLinksWithElectron = false;

      hardwareAcceleration = true;
      hardwareVideoAcceleration = true;

      arRPC = false;

      enableSplashScreen = true;
      splashTheming = true;

      checkUpdates = false;
    };
  };
}
