{
  userConfig,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./homebrew
    ./security
    ./dock
  ];

  # It me
  users.users.${userConfig.username} = {
    name = "${userConfig.username}";
    home = "/Users/${userConfig.username}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs userConfig;
    };
    users.${userConfig.username} = {
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix {};
        stateVersion = "23.11";
      };
      imports = [
        ./home-manager
      ];

      # Marked broken Oct 20, 2022 check later to remove this
      # https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };
}
