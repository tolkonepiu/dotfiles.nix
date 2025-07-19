{userConfig, ...}: {
  imports = [
    ./nix-settings.nix
    ../../modules/darwin
    ../../modules/shared
  ];

  system = {
    stateVersion = 6;

    primaryUser = "${userConfig.username}";
    checks = {
      verifyNixPath = false;
    };

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;
        AppleEnableSwipeNavigateWithScrolls = true;

        KeyRepeat = 2; # Values: 120, 90, 60, 30, 12, 6, 2
        InitialKeyRepeat = 15; # Values: 120, 94, 68, 35, 25, 15

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
      };

      finder = {
        _FXShowPosixPathInTitle = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };
  };
}
