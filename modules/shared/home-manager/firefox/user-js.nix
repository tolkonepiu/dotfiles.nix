{
  lib,
  pkgs,
  userConfig,
  ...
}:
let
  betterfox = pkgs.fetchFromGitHub {
    owner = "yokoffing";
    repo = "Betterfox";
    rev = "82553f016744f0eb0528f8d92c3eb30ef9a1f6c4";
    hash = "sha256-jmZ1DTdND9wpPtPZ3TgJhgZc0ed+dre8mRUaA2llBL0=";
  };
in
{
  programs.firefox.profiles."${userConfig.username}.default" = {
    settings = {
      # Vertical tabs
      "sidebar.verticalTabs" = true;
      "sidebar.visibility" = "expand-on-hover";

      # https://github.com/yokoffing/Betterfox/blob/main/Smoothfox.js
      # Recommended for 60hz+ displays
      "apz.overscroll.enabled" = lib.mkDefault true;
      "general.smoothScroll" = lib.mkDefault true;
      "mousewheel.default.delta_multiplier_y" = lib.mkDefault 275;
      "general.smoothScroll.msdPhysics.enabled" = lib.mkDefault false;
    };

    extraConfig = lib.strings.concatLines [
      # Betterfox
      (builtins.readFile "${betterfox}/Peskyfox.js")
      (builtins.readFile "${betterfox}/Fastfox.js")
    ];
  };
}
