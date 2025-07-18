{
  userConfig,
  config,
  ...
}: {
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
        app = "${config.home-manager.users.${userConfig.username}.programs.firefox.finalPackage}/Applications/Firefox Developer Edition.app";
      }
      {
        app = "/Applications/Obsidian.app";
      }
      {
        app = "/Applications/Visual Studio Code - Insiders.app";
      }
      {
        app = "${config.home-manager.users.${userConfig.username}.programs.spicetify.spicedSpotify}/Applications/Spotify.app";
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
