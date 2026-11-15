{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.deck-gaming-profiles;
  settings = lib.recursiveUpdate (import ./profiles.nix) cfg.settings;
  package = import ./package.nix {inherit pkgs settings;};
  validWatts = watts: builtins.isInt watts && watts > 0 && watts <= 15;
  state = "/run/deck-gaming-power/snapshot.json";
in {
  options.services.deck-gaming-profiles = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable host-local Steam game display and power profiles.";
    };
    settings = lib.mkOption {
      inherit (pkgs.formats.json {}) type;
      default = {};
      description = "Partial profile and per-AppID overrides, recursively merged with profiles.nix.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.all (name:
          settings.profiles.${name}.output
          == {
            width = 1280;
            height = 800;
            hz = 60;
          }) ["handheld-battery" "handheld-ac"];
        message = "deck-gaming-profiles: the LCD internal output is fixed at 1280x800@60 (DRM panel rotation is separate).";
      }
      {
        assertion =
          builtins.isAttrs settings.profiles
          && lib.all (
            profile:
              builtins.isAttrs profile && profile ? watts && validWatts profile.watts
          ) (builtins.attrValues settings.profiles);
        message = "deck-gaming-profiles: profile watts must be an integer from 1 to 15 W.";
      }
      {
        assertion =
          builtins.isAttrs settings.games
          && lib.all (
            game:
              builtins.isAttrs game
              && (!(game ? power)
                || (builtins.isAttrs game.power && lib.all validWatts (builtins.attrValues game.power)))
          ) (builtins.attrValues settings.games);
        message = "deck-gaming-profiles: game power overrides must be an integer from 1 to 15 W.";
      }
    ];

    system.build.deck-gaming-profiles = package;
    environment.systemPackages = [package];

    # The root broker alone owns TDP; retain Jovian's GPU clock permissions.
    jovian.devices.steamdeck.enablePerfControlUdevRules = lib.mkForce false;
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="pci", DRIVER=="amdgpu", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/%p/power_dpm_force_performance_level /sys/%p/pp_od_clk_voltage"
      ACTION=="add", SUBSYSTEM=="hwmon", ATTR{name}=="amdgpu", RUN+="${pkgs.coreutils}/bin/chown root:root /sys/%p/power1_cap /sys/%p/power2_cap", RUN+="${pkgs.coreutils}/bin/chmod 0644 /sys/%p/power1_cap /sys/%p/power2_cap"
    '';

    systemd.services.deck-gaming-power = {
      description = "Steam Deck gaming power broker";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        User = "root";
        RuntimeDirectory = "deck-gaming-power";
        RuntimeDirectoryMode = "0755";
        RuntimeDirectoryPreserve = "yes";
        ExecStart = "${package}/bin/deck-gaming-power daemon --socket /run/deck-gaming-power/control.sock --state ${state} --user ${config.jovian.steam.user}";
        ExecStopPost = "${package}/bin/deck-gaming-power restore --state ${state}";
        Restart = "on-failure";
        RestartSec = 3;
      };
    };

    systemd.user.services.deck-gaming-profiles = {
      description = "Automatic Steam Deck gaming profiles";
      after = ["gamescope-session.service"];
      requires = ["gamescope-session.service"];
      partOf = ["gamescope-session.target"];
      bindsTo = ["gamescope-session.target"];
      wantedBy = ["gamescope-session.target"];
      unitConfig.ConditionUser = config.jovian.steam.user;
      serviceConfig = {
        ExecStart = "${package}/bin/deck-gaming-profiles daemon";
        TimeoutStopSec = 30;
        Restart = "on-failure";
        RestartSec = 1;
      };
    };
  };
}
