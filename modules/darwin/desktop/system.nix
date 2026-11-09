{
  system.defaults = {
    CustomUserPreferences = {
      # Login Window settings
      "com.apple.loginwindow" = {
        # Disable automatic relaunch of apps on login
        LoginwindowLaunchesRelaunchApps = false;
        # Don't restore windows from previous session
        TALLogoutSavesState = false;
      };
      "com.apple.desktopservices" = {
        # Avoid creating .DS_Store files on network or USB volumes
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
    };
  };
}
