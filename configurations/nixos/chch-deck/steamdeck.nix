{flake, ...}: {
  imports = [
    flake.inputs.chaotic.nixosModules.default
    flake.inputs.chaotic.vendored.jovian.nixosModules.default
    ./emulators
    ./gaming-profiles
  ];

  jovian = {
    devices.steamdeck = {
      enable = true;
      # Update BIOS and controller firmware at boot, subject to Valve's checks.
      autoUpdate = true;
      # Gaming profiles replace TDP access; retain vendor rules when disabled.
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
}
