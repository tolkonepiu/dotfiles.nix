{
  userConfig,
  pkgs,
  ...
}:

{
  imports = [ ./dock.nix ];

  system.defaults.dock = {
    autohide = true;
    show-recents = false;
    launchanim = true;
    orientation = "bottom";
    tilesize = 64;
  };

  # Fully declarative dock using the latest from Nix Store
  local.dock = {
    enable = true;
    username = "${userConfig.username}";
    entries = [
      { path = "/System/Applications/Launchpad.app"; }
      { path = "/Applications/iTerm.app"; }
      { path = "${pkgs.firefox}/Applications/Firefox.app"; }
      { path = "/Applications/Obsidian.app"; }
      { path = "/Applications/Visual Studio Code - Insiders.app"; }
      { path = "/Applications/ChatGPT.app"; }
      { path = "/Applications/Telegram.app"; }
      { path = "/Applications/Mattermost.app"; }
    ];
  };
}
