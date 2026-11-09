{
  config,
  flake,
  ...
}: let
  user = config.jovian.steam.user;
  group = config.users.users.${user}.group;
in {
  imports = [
    flake.inputs.chaotic.nixosModules.default
    flake.inputs.chaotic.vendored.jovian.nixosModules.default
    ./emulators
  ];

  jovian = {
    devices.steamdeck = {
      enable = true;
      # Update BIOS and controller firmware at boot, subject to Valve's checks.
      autoUpdate = true;
      # Allow Steam to control TDP and GPU clocks.
      enablePerfControlUdevRules = true;
      # Use Valve's software-controlled fan curve.
      enableOsFanControl = true;
    };
    steam = {
      enable = true;
      autoStart = true;
      user = "chch";
      desktopSession = "niri";
    };
    # Match Steam's user for access to its graphical session.
    decky-loader = {
      enable = true;
      user = "chch";
    };
  };

  # Allow games to request temporary performance optimizations.
  programs.gamemode.enable = true;
  # Enable Steam Input keyboard/mouse emulation on Wayland via uinput.
  programs.steam.extest.enable = true;

  # Only run the vendor's firmware updaters while connected to external power.
  systemd.services = {
    jupiter-biosupdate = {
      overrideStrategy = "asDropin";
      unitConfig.ConditionACPower = true;
    };
    jupiter-controller-update = {
      overrideStrategy = "asDropin";
      unitConfig.ConditionACPower = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /games 0755 ${user} ${group} -"
    "d /games/SteamLibrary 0755 ${user} ${group} -"
  ];
}
