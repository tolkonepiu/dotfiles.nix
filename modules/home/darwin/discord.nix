{
  programs.vesktop = {
    enable = true;
    vencord = {
      useSystem = true;
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
