{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    includes = [
      "${config.home.homeDirectory}/.ssh/config_external"
    ];

    matchBlocks = lib.mkMerge [
      {
        "*" = {
          forwardAgent = false;
          addKeysToAgent = "yes";
          compression = true;
          serverAliveInterval = 60;
          serverAliveCountMax = 3;
          hashKnownHosts = true;
          userKnownHostsFile = "${config.home.homeDirectory}/.ssh/known_hosts";
          controlMaster = "auto";
          controlPath = "${config.home.homeDirectory}/.ssh/master-%r@%n:%p";
          controlPersist = "10m";
        };
      }

      (lib.mkIf isDarwin {
        "*" = {
          identityAgent = "${config.home.homeDirectory}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
        };
      })
    ];
  };
}
