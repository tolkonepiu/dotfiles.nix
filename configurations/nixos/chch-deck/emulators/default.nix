{config, ...}: let
  inherit (import ./paths.nix) root roms bios;
  user = config.jovian.steam.user;
  group = config.users.users.${user}.group;
  configHome = config.home-manager.users.${user}.xdg.configHome;
in {
  imports = [
    ./cemu.nix
    ./eden.nix
    ./retroarch.nix
    ./xenia.nix
  ];

  jovian.devices.steamdeck.enableGyroDsuService = true;

  systemd.tmpfiles.rules =
    (map (path: "d ${path} 0755 ${user} ${group} -") [
      "/games"
      "/games/SteamLibrary"
      root
      bios
      roms
    ])
    ++ ["d ${configHome} - ${user} ${group} -"];
}
