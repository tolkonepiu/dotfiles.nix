{
  userConfig,
  ...
}:
{
  imports = [
    ./extensions.nix
    ./policies.nix
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
    colorTheme.enable = true;
    profileNames = [
      "${userConfig.username}.default"
    ];
  };
}
