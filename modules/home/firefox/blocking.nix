_: {
  programs.firefox.profiles.default.extensions.settings = {
    "uBlock0@raymondhill.net".settings = {
      selectedFilterLists = [
        # Built-in
        "ublock-filters"
        "ublock-badware"
        "ublock-privacy"
        "ublock-quick-fixes"
        "ublock-unbreak"
        # Ads
        "easylist"
        "adguard-generic"
        # Privacy
        "easyprivacy"
        "adguard-spyware-url"
        "block-lan"
        # Malware protection, security
        "urlhaus-1"
        "curben-phishing"
        # Multipurpose
        "plowe-0"
        "dpollock-0"
        # Cookie notices
        "fanboy-cookiemonster"
        "ublock-cookies-easylist"
        "adguard-cookies"
        "ublock-cookies-adguard"
        # Social widgets
        "fanboy-social"
        "adguard-social"
        "fanboy-thirdparty_social"
        # Annoyances
        "fanboy-ai-suggestions"
        "easylist-chat"
        "easylist-newsletters"
        "easylist-notifications"
        "easylist-annoyances"
        "adguard-mobile-app-banners"
        "adguard-other-annoyances"
        "adguard-popup-overlays"
        "adguard-widgets"
        "ublock-annoyances"
        # Regions
        "RUS-0"
        "RUS-1"
        # Custom
        "https://raw.githubusercontent.com/gijsdev/ublock-hide-yt-shorts/master/list.txt"
      ];

      externalLists = [
        # Hide YouTube shorts
        "https://raw.githubusercontent.com/gijsdev/ublock-hide-yt-shorts/master/list.txt"
      ];
    };
  };
}
