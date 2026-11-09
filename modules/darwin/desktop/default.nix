{
  imports = [
    ./homebrew
    ./finder.nix
    ./dock.nix
    ./paneru.nix
    ./system.nix
    ./trackpad.nix
  ];

  system.defaults.NSGlobalDomain = {
    AppleShowAllExtensions = true;
    ApplePressAndHoldEnabled = false;

    KeyRepeat = 2;
    InitialKeyRepeat = 15;

    "com.apple.mouse.tapBehavior" = 1;
    "com.apple.sound.beep.volume" = 0.0;
    "com.apple.sound.beep.feedback" = 0;
  };
}
