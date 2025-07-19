{
  userConfig,
  config,
  ...
}: let
  programs = config.home-manager.users.${userConfig.username}.programs;
in {
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
        app = "${programs.ghostty.package}/Applications/Ghostty.app";
      }
      {
        app = "${programs.firefox.finalPackage}/Applications/Firefox.app";
      }
      {
        app = "/Applications/Obsidian.app";
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
