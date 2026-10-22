{
  config,
  flake,
  pkgs,
  ...
}: {
  imports = [
    flake.inputs.self.nixosModules.default
    flake.inputs.chaotic.vendored.jovian.nixosModules.default
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
  # Jovian autoStart manages session selection between Gaming Mode and niri.
  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    fuzzel
    waybar
    swaylock
    brightnessctl
    playerctl
    xwayland-satellite
  ];
  security.pam.services.swaylock = {};

  home-manager.users.chch.xdg.configFile."niri/config.kdl".source = pkgs.runCommand "niri-config.kdl" {} ''
    cp ${config.programs.niri.package.src}/resources/default-config.kdl "$out"
    chmod u+w "$out"
    substituteInPlace "$out" --replace-fail alacritty ghostty
  '';

  systemd.tmpfiles.rules = [
    "d /games 0755 chch users -"
    "d /games/SteamLibrary 0755 chch users -"
  ];

  system.stateVersion = "26.11";
}
