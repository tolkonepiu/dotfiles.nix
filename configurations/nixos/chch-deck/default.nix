{flake, ...}: {
  imports = [
    flake.inputs.self.nixosModules.default
    flake.inputs.chaotic.vendored.jovian.nixosModules.default
    ./boot.nix
    ./disko.nix
    ./updater.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "chch-deck";

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = ["nvme"];
  };

  jovian = {
    devices.steamdeck = {
      enable = true;
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
    # Enable Decky Loader in Steam Gaming Mode.
    decky-loader.enable = true;
  };
  # Jovian switches between Gaming Mode and the native niri session.

  home-manager.sharedModules = [./niri.nix ./noctalia.nix];

  # Compressed RAM swap for memory-heavy games and emulators.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # Periodically trim unused blocks on the SSD.
  services.fstrim.enable = true;
  # Allow games to request temporary performance optimizations.
  programs.gamemode.enable = true;
  # Enable Steam Input keyboard/mouse emulation on Wayland (Niri) via uinput
  programs.steam.extest.enable = true;

  systemd.tmpfiles.rules = [
    "d /games 0755 chch users -"
    "d /games/SteamLibrary 0755 chch users -"
  ];

  system.stateVersion = "26.11";
}
