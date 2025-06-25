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
        "ublock-annoyances"
        "easylist"
        "easyprivacy"
        "adguard-spyware-url"
        "adguard-spyware"
        "adguard-cookies"
        "ublock-cookies-adguard"
        "ublock-cookies-easylist"
        "fanboy-cookiemonster"
        "adguard-social"
        "fanboy-social"
        "fanboy-thirdparty_social"
        "block-lan"
        "RUS-0"
        "RUS-1"
      ];
    };
  };
}
