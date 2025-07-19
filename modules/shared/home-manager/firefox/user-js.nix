{
  lib,
  inputs,
  ...
}: {
  programs.firefox.profiles.default = {
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

    preConfig = lib.strings.concatLines [
      # Betterfox
      (builtins.readFile "${inputs.betterfox}/Peskyfox.js")
      (builtins.readFile "${inputs.betterfox}/Fastfox.js")
      (builtins.readFile "${inputs.betterfox}/Securefox.js")
    ];
  };
}
