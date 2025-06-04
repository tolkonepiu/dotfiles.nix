{
  config,
  pkgs,
  lib,
  home-manager,
  zdotdir,
  userConfig,
  ...
}:

let
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix {
    inherit
      lib
      userConfig
      config
      pkgs
      ;
  };
in
{
  imports = [ ./dock ];

  # It me
  users.users.${userConfig.username} = {
    name = "${userConfig.username}";
    home = "/Users/${userConfig.username}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix { };
    # onActivation.cleanup = "uninstall";

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    # If you have previously added these apps to your Mac App Store profile (but not installed them on this system),
    # you may receive an error message "Redownload Unavailable with This Apple ID".
    # This message is safe to ignore. (https://github.com/dustinlyons/nixos-config/issues/83)
    masApps = {
      "amphetamine" = 937984704;
      "mattermost" = 1614666244;
      "telegram" = 747648890;
      "wireguard" = 1451685025;
    };
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${userConfig.username} =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      {
        # Pass the zdotdir parameter explicitly to the home-manager modules
        _module.args = {
          zdotdir = zdotdir;
          userConfig = userConfig;
        };

        home = {
          enableNixpkgsReleaseCheck = false;
          packages = pkgs.callPackage ./packages.nix { };
          file = lib.mkMerge [
            sharedFiles
            additionalFiles
          ];
          stateVersion = "23.11";
        };
        programs = { };
        imports = [
          ./home-manager
        ];

        # Marked broken Oct 20, 2022 check later to remove this
        # https://github.com/nix-community/home-manager/issues/3344
        manual.manpages.enable = false;
      };
  };

  # Fully declarative dock using the latest from Nix Store
  local.dock = {
    enable = true;
    username = "${userConfig.username}";
    entries = [
      { path = "/System/Applications/Launchpad.app"; }
      { path = "/Applications/iTerm.app"; }
      { path = "/${pkgs.firefox-devedition}/Applications/Firefox Developer Edition.app"; }
      { path = "/Applications/Obsidian.app"; }
      { path = "/Applications/Visual Studio Code - Insiders.app"; }
      { path = "/Applications/ChatGPT.app"; }
      { path = "/Applications/Telegram.app"; }
      { path = "/Applications/Mattermost.app"; }
    ];
  };

}
