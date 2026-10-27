{config, ...}: let
  user = config.jovian.steam.user;
  group = config.users.users.${user}.group;
  configHome = config.home-manager.users.${user}.xdg.configHome;
  paths = import ./paths.nix;
in {
  imports = [
    ./cemu.nix
    ./xenia-canary.nix
    ./eden.nix
    ./retroarch.nix
  ];

  systemd.tmpfiles.rules =
    (map (path: "d ${path} 0755 ${user} ${group} -") [
      paths.root
      paths.bios
      paths.roms
      paths.saves
      paths.states
    ])
    ++ ["d ${configHome} - ${user} ${group} -"];
}
