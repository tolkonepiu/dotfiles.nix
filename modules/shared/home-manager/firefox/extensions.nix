{
  programs.firefox.policies.ExtensionSettings = {
    "*".installation_mode = "blocked"; # blocks all addons except the ones specified below

    # uBlock Origin
    "uBlock0@raymondhill.net" = {
      "installation_mode" = "force_installed";
      "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
      "default_area" = "menupanel";
      "private_browsing" = true;
    };

    # Stylus
    "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}" = {
      "installation_mode" = "force_installed";
      "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/styl-us/latest.xpi";
      "default_area" = "menupanel";
    };

    # SponsorBlock for YouTube
    "sponsorBlocker@ajay.app" = {
      "installation_mode" = "force_installed";
      "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
      "default_area" = "menupanel";
    };

    # Obsidian Web Clipper
    "clipper@obsidian.md" = {
      "installation_mode" = "force_installed";
      "install_url" =
        "https://addons.mozilla.org/firefox/downloads/latest/web-clipper-obsidian/latest.xpi";
      "default_area" = "navbar";
    };

    # Firefox Multi-Account Containers
    "@testpilot-containers" = {
      "installation_mode" = "force_installed";
      "install_url" =
        "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
      "default_area" = "menupanel";
    };

    # Firefox Color
    "FirefoxColor@mozilla.com" = {
      "installation_mode" = "force_installed";
      "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/firefox-color/latest.xpi";
      "default_area" = "menupanel";
    };

    # Refined GitHub
    "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}" = {
      "installation_mode" = "force_installed";
      "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/refined-github-/latest.xpi";
      "default_area" = "menupanel";
    };

    # Augmented Steam
    "{1be309c5-3e4f-4b99-927d-bb500eb4fa88}" = {
      "installation_mode" = "force_installed";
      "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/augmented-steam/latest.xpi";
      "default_area" = "menupanel";
    };
  };
}
