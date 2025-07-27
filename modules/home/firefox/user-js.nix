{
  flake,
  pkgs,
  lib,
  ...
}: let
  inherit (flake) inputs;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  programs.firefox.profiles.default = {
    settings = lib.mkMerge [
      # Common settings
      {
        # Vertical tabs
        "sidebar.verticalTabs" = true;
        "sidebar.visibility" = "expand-on-hover";
      }
      #Smoothfox
      # https://github.com/yokoffing/Betterfox/blob/main/Smoothfox.js
      (
        {
          # Recommended for 60hz+ displays
          "apz.overscroll.enabled" = true;
          "general.smoothScroll" = true;
          "mousewheel.default.delta_multiplier_y" = 275;
          "general.smoothScroll.msdPhysics.enabled" = false;
        }
        // lib.mkIf isDarwin {
          # Recommended for 120hz+ displays
          "apz.overscroll.enabled" = true;
          "general.smoothScroll" = true;
          "general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS" = 12;
          "general.smoothScroll.msdPhysics.enabled" = true;
          "general.smoothScroll.msdPhysics.motionBeginSpringConstant" = 600;
          "general.smoothScroll.msdPhysics.regularSpringConstant" = 650;
          "general.smoothScroll.msdPhysics.slowdownMinDeltaMS" = 25;
          "general.smoothScroll.msdPhysics.slowdownMinDeltaRatio" = "2";
          "general.smoothScroll.msdPhysics.slowdownSpringConstant" = 250;
          "general.smoothScroll.currentVelocityWeighting" = "1";
          "general.smoothScroll.stopDecelerationWeighting" = "1";
          "mousewheel.default.delta_multiplier_y" = 300;
        }
      )
    ];

    preConfig = lib.strings.concatLines [
      # Betterfox
      (builtins.readFile "${inputs.betterfox}/Peskyfox.js")
      (builtins.readFile "${inputs.betterfox}/Fastfox.js")
      (builtins.readFile "${inputs.betterfox}/Securefox.js")
    ];
  };
}
