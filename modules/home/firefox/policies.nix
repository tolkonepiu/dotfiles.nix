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
    GenerativeAI = {
      Enabled = false;
      Chatbot = false;
      SmartWindow = false;
      LinkPreviews = false;
      TabGroups = false;
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
  };
}
