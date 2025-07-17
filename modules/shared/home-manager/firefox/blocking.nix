{
  lib,
  pkgs,
  userConfig,
  ...
}: {
  programs.firefox.profiles."${userConfig.username}.default".extensions.settings = {
    "uBlock0@raymondhill.net".settings = {
      selectedFilterLists = [
        "ublock-filters"
        "ublock-badware"
        "ublock-privacy"
        "ublock-quick-fixes"
        "ublock-unbreak"
        "easylist"
        "easyprivacy"
        "adguard-spyware"
        "adguard-spyware-url"
        "block-lan"
        "urlhaus-1"
        "curben-phishing"
        "plowe-0"
        "fanboy-cookiemonster"
        "ublock-cookies-easylist"
        "adguard-cookies"
        "ublock-cookies-adguard"
        "fanboy-social"
        "adguard-social"
        "fanboy-thirdparty_social"
        "easylist-chat"
        "easylist-newsletters"
        "easylist-notifications"
        "easylist-annoyances"
        "adguard-mobile-app-banners"
        "adguard-other-annoyances"
        "adguard-popup-overlays"
        "adguard-widgets"
        "ublock-annoyances"
        "RUS-0"
        "RUS-1"
      ];
    };
  };
}
