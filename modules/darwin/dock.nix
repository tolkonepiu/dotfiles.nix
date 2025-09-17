{config, ...}: let
  inherit (config.home-manager.users.${config.system.primaryUser}) programs;
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
        app = "/Applications/iTerm.app";
      }
      {
        app = "${programs.firefox.finalPackage}/Applications/Firefox.app";
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
        app = "${programs.spicetify.spicedSpotify}/Applications/Spotify.app";
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
