{
  programs.firefox.policies = {
    DisplayBookmarksToolbar = "never";

    DisableFirefoxAccounts = true;
    PasswordManagerEnabled = false;
    AutofillAddressEnabled = false;
    AutofillCreditCardEnabled = false;
    DisablePocket = true;
    DisableTelemetry = true;
    HardwareAcceleration = true;
    DisableFirefoxStudies = true;
    DisableFirefoxScreenshots = true;
    NoDefaultBookmarks = true;
    SearchSuggestEnabled = false;
    DisableFormHistory = true;
    Preferences."places.history.enabled" = {
      Value = false;
      Status = "locked";
    };
    DontCheckDefaultBrowser = true;
    FirefoxHome = {
      Search = true;
      TopSites = true;
      SponsoredTopSites = false;
      Highlights = false;
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
    AIControls = {
      Default = {
        Value = "blocked";
        Locked = true;
      };
      Translations = {
        Value = "blocked";
        Locked = true;
      };
      PDFAltText = {
        Value = "blocked";
        Locked = true;
      };
      SmartTabGroups = {
        Value = "blocked";
        Locked = true;
      };
      LinkPreviewKeyPoints = {
        Value = "blocked";
        Locked = true;
      };
      SidebarChatbot = {
        Value = "blocked";
        Locked = true;
      };
      SmartWindow = {
        Value = "blocked";
        Locked = true;
      };
    };
    ExtensionUpdate = true;
    SearchEngines = {
      Default = "DuckDuckGo";
      Remove = [
        "Amazon.com"
        "Bing"
        "eBay"
        "Perplexity"
      ];
    };
  };
}
