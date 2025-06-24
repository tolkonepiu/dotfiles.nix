{
  home-manager,
  userConfig,
  pkgs,
  lib,
  ...
}:

{
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
    users.${userConfig.username} =
      {
        pkgs,
        lib,
        ...
      }:
      {
        # Pass the userConfig parameters explicitly to the home-manager modules
        _module.args = {
          userConfig = userConfig;
        };

        home = {
          enableNixpkgsReleaseCheck = false;
          packages = pkgs.callPackage ./packages.nix { };
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
