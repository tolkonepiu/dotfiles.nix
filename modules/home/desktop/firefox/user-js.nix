{
  flake,
  pkgs,
  lib,
  ...
}: let
  inherit (flake) inputs;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  options.programs.firefox.profiles = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      config = {
        settings = lib.mkMerge [
          # Common settings
          {
            # Restore this pinned toolbar layout on each startup, clearing tab-orientation snapshots.
            "browser.uiCustomization.state" = {
              placements = {
                widget-overflow-fixed-list = [];
                nav-bar = [
                  "alltabs-button"
                  "sidebar-button"
                  "back-button"
                  "forward-button"
                  "stop-reload-button"
                  "vertical-spacer"
                  "urlbar-container"
                  "downloads-button"
                  "developer-button"
                  "reset-pbm-toolbar-button"
                  "unified-extensions-button"
                ];
                TabsToolbar = [];
                vertical-tabs = ["tabbrowser-tabs"];
                PersonalToolbar = ["personal-bookmarks"];
              };
              currentVersion = 100;
            };
            "browser.uiCustomization.horizontalTabstrip" = "";
            "browser.uiCustomization.navBarWhenVerticalTabs" = "";

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
            // lib.optionalAttrs isDarwin {
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
          (builtins.readFile "${inputs.betterfox}/user.js")
        ];
      };
    });
  };
}
