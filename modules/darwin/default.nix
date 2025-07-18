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
        stateVersion = "25.05";
      };
      imports = [
        ./home-manager
      ];
    };
  };
}
