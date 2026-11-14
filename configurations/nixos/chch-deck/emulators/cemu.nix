{config, ...}: let
  inherit (import ./paths.nix) roms;
  user = config.jovian.steam.user;
  group = config.users.users.${user}.group;
  romsDir = "${roms}/wiiu";

  # Targets Gaming Mode's Steam Input gamepad layout (EmuDeck's standard GUID).
  # Other controller GUIDs must be selected in Cemu's Input settings.
  controller = {
    type = "Wii U GamePad";
    profile = "SteamDeck";
    controller = [
      {
        api = "DSUController";
        uuid = "0";
        display_name = "Steam Deck Gyroscope";
        motion = true;
        mappings = {};
      }
      {
        api = "SDLController";
        uuid = "0_030079f6de280000ff11000001000000";
        display_name = "Steam Virtual Gamepad";
        motion = false;
        rumble = 1;
        axis = {
          deadzone = 0.1;
          range = 1;
        };
        rotation = {
          deadzone = 0.1;
          range = 1;
        };
        trigger = {
          deadzone = 0.1;
          range = 1;
        };
        mappings.entry = [
          # Steam Input already handles the Nintendo face-button swap.
          {
            mapping = 1;
            button = 0;
          }
          {
            mapping = 2;
            button = 1;
          }
          {
            mapping = 3;
            button = 2;
          }
          {
            mapping = 4;
            button = 3;
          }
          # Shoulders and triggers
          {
            mapping = 5;
            button = 9;
          }
          {
            mapping = 6;
            button = 10;
          }
          {
            mapping = 7;
            button = 42;
          }
          {
            mapping = 8;
            button = 43;
          }
          # Plus and minus
          {
            mapping = 9;
            button = 6;
          }
          {
            mapping = 10;
            button = 4;
          }
          # D-pad
          {
            mapping = 11;
            button = 11;
          }
          {
            mapping = 12;
            button = 12;
          }
          {
            mapping = 13;
            button = 13;
          }
          {
            mapping = 14;
            button = 14;
          }
          # Stick clicks
          {
            mapping = 15;
            button = 7;
          }
          {
            mapping = 16;
            button = 8;
          }
          # Left stick: up, down, left, right
          {
            mapping = 17;
            button = 45;
          }
          {
            mapping = 18;
            button = 39;
          }
          {
            mapping = 19;
            button = 44;
          }
          {
            mapping = 20;
            button = 38;
          }
          # Right stick: up, down, left, right
          {
            mapping = 21;
            button = 47;
          }
          {
            mapping = 22;
            button = 41;
          }
          {
            mapping = 23;
            button = 46;
          }
          {
            mapping = 24;
            button = 40;
          }
        ];
      }
    ];
  };
in {
  home-manager.users.${user}.programs.cemu = {
    settings = {
      fullscreen = true;
      GamePaths.Entry = romsDir;
      Input.DSUC = {
        "@host" = "127.0.0.1";
        "@port" = 26760;
      };
    };
    controllerProfiles = {
      controller0 = controller;
      SteamDeck = controller;
    };
  };

  jovian.decky-loader.extraPackages = [config.home-manager.users.${user}.programs.cemu.package];

  systemd.tmpfiles.rules = ["d ${romsDir} 0755 ${user} ${group} -"];
}
