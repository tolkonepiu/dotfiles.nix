{
  programs.firefox.policies = {
    DisplayBookmarksToolbar = "never";

    DisableFirefoxAccounts = false;
    PasswordManagerEnabled = true;
    DisablePocket = true;
    DisableTelemetry = true;
    HardwareAcceleration = true;
    DisableFirefoxStudies = true;
    DisableFirefoxScreenshots = true;
    NoDefaultBookmarks = true;
    SearchSuggestEnabled = false;
    DisableFormHistory = true;
    DontCheckDefaultBrowser = true;
    FirefoxHome = {
      Search = true;
      TopSites = true;
      SponsoredTopSites = false;
      Highlights = true;
      Pocket = false;
      SponsoredPocket = false;
      Snippets = true;
      Locked = true;
    };
    UserMessaging = {
      WhatsNew = false;
      ExtensionRecommendations = false;
      SkipOnboarding = true;
      MoreFromMozilla = false;
      Locked = true;
    };
    FirefoxSuggest = {
      WebSuggestions = false;
      SponsoredSuggestions = false;
      ImproveSuggest = false;
      Locked = true;
    };
    ExtensionUpdate = true;
  };
}
