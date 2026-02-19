{pkgs, ...}: {
  imports = [
    ./extensions.nix
    ./policies.nix
    ./blocking.nix
    ./user-js.nix
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-bin;

    languagePacks = [
      "en-US"
      "ru"
    ];

    profiles.default = {
      id = 0;
      isDefault = true;
      name = "default";
      extensions = {
        force = true;
      };
    };
  };

  catppuccin.firefox.profiles = {
    default.enable = true;
  };
}
