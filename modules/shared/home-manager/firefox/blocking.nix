{
  lib,
  pkgs,
  userConfig,
  ...
}:
{
  programs.firefox.profiles."${userConfig.username}.default".extensions.settings = {
    "uBlock0@raymondhill.net".settings = {
      selectedFilterLists = [
        "ublock-filters"
        "ublock-badware"
        "ublock-privacy"
        "ublock-unbreak"
        "ublock-quick-fixes"
        "easylist"
        "easyprivacy"
        "adguard-spyware-url"
        "adguard-spyware"
        "block-lan"
        "RUS-0"
        "RUS-1"
      ];
    };
  };
}
