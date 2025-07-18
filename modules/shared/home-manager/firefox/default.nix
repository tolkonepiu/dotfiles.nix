{pkgs, ...}: {
  imports = [
    ./extensions.nix
    ./policies.nix
    ./blocking.nix
    ./user-js.nix
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition;

    languagePacks = [
      "en-US"
      "ru"
    ];

    profiles."dev-edition-default" = {
      id = 0;
      isDefault = true;
      name = "dev-edition-default";
      extensions = {
        force = true;
      };
    };
  };

  catppuccin.firefox.profiles = {
    "dev-edition-default".enable = true;
  };
}
