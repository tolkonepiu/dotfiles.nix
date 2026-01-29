{config, ...}: let
  inherit (config.home-manager.users.${config.system.primaryUser}.home) homeDirectory;
in {
  system.defaults.dock = {
    autohide = true;
    show-recents = false;
    launchanim = true;
    orientation = "bottom";
    tilesize = 64;

    persistent-apps = [
      {
        app = "/System/Applications/Apps.app";
      }
      {
        app = "${homeDirectory}/Applications/Home Manager Apps/Ghostty.app";
      }
      {
        app = "${homeDirectory}/Applications/Home Manager Apps/Firefox.app";
      }
      {
        app = "/Applications/Obsidian.app";
      }
      {
        app = "/Applications/Cursor.app";
      }
      {
        app = "/Applications/Visual Studio Code - Insiders.app";
      }
      {
        app = "${homeDirectory}/Applications/Home Manager Apps/Spotify.app";
      }
      {
        app = "/Applications/ChatGPT.app";
      }
      {
        app = "/Applications/Telegram.app";
      }
      {
        app = "/Applications/Mattermost.app";
      }
    ];
  };
}
