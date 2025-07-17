{userConfig, ...}: {
  imports = [
    ./extensions.nix
    ./policies.nix
    ./blocking.nix
    ./user-js.nix
    ./theme.nix
  ];

  programs.firefox = {
    enable = true;

    languagePacks = [
      "en-US"
      "ru"
    ];

    profiles."${userConfig.username}.default" = {
      id = 0;
      isDefault = true;
      name = "${userConfig.username}.default";
      extensions = {
        force = true;
      };
    };
  };

  stylix.targets.firefox = {
    profileNames = [
      "${userConfig.username}.default"
    ];
  };
}
