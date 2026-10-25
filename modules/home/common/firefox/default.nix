{pkgs, ...}: {
  imports = [
    ./extensions.nix
    ./policies.nix
    ./blocking.nix
    ./user-js.nix
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    languagePacks = [
      "en-US"
      "ru"
    ];

    profiles = {
      default = {
        id = 0;
        isDefault = true;
        name = "default";
        extensions = {
          force = true;
        };
      };
      work = {
        id = 1;
        isDefault = false;
        name = "work";
        extensions = {
          force = true;
        };
      };
    };
  };

  catppuccin.firefox.profiles = {
    default.enable = true;
  };
}
