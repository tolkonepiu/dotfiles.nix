let
  extensions = {
    # uBlock Origin
    "uBlock0@raymondhill.net" = "ublock-origin";
    # Stylus
    "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}" = "styl-us";
    # SponsorBlock for YouTube
    "sponsorBlocker@ajay.app" = "sponsorblock";
    # Return YouTube Dislike
    "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = "return-youtube-dislikes";
    # Karakeep
    "addon@karakeep.app" = "karakeep";
    # Firefox Color
    "FirefoxColor@mozilla.com" = "firefox-color";
    # Refined GitHub
    "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}" = "refined-github-";
    # Augmented Steam
    "{1be309c5-3e4f-4b99-927d-bb500eb4fa88}" = "augmented-steam";
  };
  overrides = {
    "uBlock0@raymondhill.net".private_browsing = true;
  };
in {
  programs.firefox.policies.ExtensionSettings =
    builtins.mapAttrs (id: slug:
      {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
        default_area = "menupanel";
      }
      // (overrides.${id} or {}))
    extensions
    // {
      "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
    };
}
