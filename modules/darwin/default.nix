# This is your nix-darwin configuration.
# For home configuration, see /modules/home/*
{
  imports = [
    ./../common
    ./base
    ./homebrew
    ./security
    ./finder.nix
    ./dock.nix
    ./software-update.nix
    ./system.nix
  ];

  # Configure macOS system
  # See: https://github.com/ryan4yin/nix-darwin-kickstarter/blob/main/rich-demo/modules/system.nix
  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false;

      KeyRepeat = 2; # Values: 120, 90, 60, 30, 12, 6, 2
      InitialKeyRepeat = 15; # Values: 120, 94, 68, 35, 25, 15

      "com.apple.mouse.tapBehavior" = 1;
      "com.apple.sound.beep.volume" = 0.0;
      "com.apple.sound.beep.feedback" = 0;
    };
    trackpad = {
      # Enable tap to click
      Clicking = true;
      # Enable two finger right click
      TrackpadRightClick = true;
      # Enable three finger drag
      TrackpadThreeFingerDrag = true;
    };
    CustomUserPreferences = {
      "com.apple.desktopservices" = {
        # Avoid creating .DS_Store files on network or USB volumes
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
    };
  };
}
