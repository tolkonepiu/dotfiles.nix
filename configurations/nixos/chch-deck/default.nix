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
    devices.steamdeck.enable = true;
    steam = {
      enable = true;
      autoStart = true;
      user = "chch";
      desktopSession = "niri";
    };
  };
  # Jovian switches between Gaming Mode and the native niri session.

  home-manager.sharedModules = [./niri.nix ./noctalia.nix ./keyboard.nix];

  systemd.tmpfiles.rules = [
    "d /games 0755 chch users -"
    "d /games/SteamLibrary 0755 chch users -"
  ];

  system.stateVersion = "26.11";
}
