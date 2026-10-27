{config, ...}: let
  user = config.jovian.steam.user;
  group = config.users.users.${user}.group;
  paths = import ./paths.nix;
in {
  imports = [
    ./cemu.nix
    ./xenia-canary.nix
    ./eden.nix
    ./retroarch.nix
  ];

  systemd.tmpfiles.rules = map (path: "d ${path} 0755 ${user} ${group} -") [
    paths.root
    paths.bios
    paths.saves
    paths.states
  ];
}
