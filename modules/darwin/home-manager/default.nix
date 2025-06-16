{
  home-manager,
  userConfig,
  zdotdir,
  pkgs,
  lib,
  ...
}:

let
  sharedFiles = import ../../shared/files.nix { inherit pkgs; };
  additionalFiles = import ../files.nix {
    inherit
      userConfig
      pkgs
      lib
      ;
  };
in
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
        # Pass the zdotdir and userConfig parameters explicitly to the home-manager modules
        _module.args = {
          zdotdir = zdotdir;
          userConfig = userConfig;
        };

        home = {
          enableNixpkgsReleaseCheck = false;
          packages = pkgs.callPackage ../packages.nix { };
          file = lib.mkMerge [
            sharedFiles
            additionalFiles
          ];
          stateVersion = "23.11";
        };
        programs = { };
        imports = [
          # Import shared configuration
          ../../shared/home-manager

          # Include Darwin-specific modules
          ./git.nix
          ./ssh.nix
        ];

        # Marked broken Oct 20, 2022 check later to remove this
        # https://github.com/nix-community/home-manager/issues/3344
        manual.manpages.enable = false;
      };
  };
}
