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

    settings = lib.mkMerge [
      {
        "*" = {
          ForwardAgent = false;
          AddKeysToAgent = "yes";
          Compression = true;
          ServerAliveInterval = 60;
          ServerAliveCountMax = 3;
          HashKnownHosts = true;
          UserKnownHostsFile = "${config.home.homeDirectory}/.ssh/known_hosts";
          ControlMaster = "auto";
          ControlPath = "${config.home.homeDirectory}/.ssh/master-%r@%n:%p";
          ControlPersist = "10m";
        };
      }

      (lib.mkIf isDarwin {
        "*" = {
          IdentityAgent = "${config.home.homeDirectory}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
        };
      })
    ];
  };
}
