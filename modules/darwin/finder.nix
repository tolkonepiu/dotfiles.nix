{
  system.defaults = {
    finder = {
      # Show full path in finder title
      _FXShowPosixPathInTitle = true;
      # Show all file extensions
      AppleShowAllExtensions = true;
      # Disable warning when changing file extension
      FXEnableExtensionChangeWarning = false;
      # Enable quit menu item
      QuitMenuItem = true;
      # Show path bar
      ShowPathbar = true;
      # Show status bar
      ShowStatusBar = true;
    };
    CustomUserPreferences = {
      "com.apple.finder" = {
        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = true;
        ShowMountedServersOnDesktop = true;
        ShowRemovableMediaOnDesktop = true;
        _FXSortFoldersFirst = true;
        # When performing a search, search the current folder by default
        FXDefaultSearchScope = "SCcf";
      };
    };
  };
}
