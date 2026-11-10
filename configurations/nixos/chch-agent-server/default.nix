{flake, ...}: let
  inherit (flake.inputs) self;
in {
  imports = [
    self.nixosModules.base
    ./boot.nix
    ./disko.nix
  ];

  home-manager.sharedModules = [self.homeModules.dev];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking = {
    hostName = "chch-agent-server";
    networkmanager.enable = false;
    useDHCP = false;
    useNetworkd = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [22];
      allowedUDPPorts = [];
    };
  };
  # An unused second physical port must not hold up network-online.target.
  systemd.network.wait-online.anyInterface = true;
  systemd.network.networks."10-uplink" = {
    matchConfig = {
      Type = "ether";
      Kind = "!*";
    };
    networkConfig.DHCP = "yes";
  };

  users.users.chch.extraGroups = ["docker"];
  # The key-only wheel user has no password to supply to sudo.
  security.sudo.wheelNeedsPassword = false;

  virtualisation.docker = {
    enable = true;
    # Docker supports overlay2 on Btrfs without the Btrfs driver's snapshot management.
    storageDriver = "overlay2";
  };

  system.stateVersion = "26.11";
}
