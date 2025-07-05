{
  userConfig,
  ...
}:

{
  system.defaults.dock = {
    autohide = true;
    show-recents = false;
    launchanim = true;
    orientation = "bottom";
    tilesize = 64;

    persistent-apps = [
      {
        app = "/System/Applications/Launchpad.app";
      }
      {
        app = "/Applications/iTerm.app";
      }
      {
        app = "/Users/${userConfig.username}/Applications/Home Manager Apps/Firefox.app";
      }
      {
        app = "/Applications/Obsidian.app";
      }
      {
        app = "/Applications/Visual Studio Code - Insiders.app";
      }
      {
        app = "/Users/${userConfig.username}/Applications/Home Manager Apps/Spotify.app";
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
