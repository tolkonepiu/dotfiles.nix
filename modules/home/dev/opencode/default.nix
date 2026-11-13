{
  lib,
  pkgs,
  ...
}: let
  readRoots =
    ["/nix/store" "/tmp" "/var/tmp"]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      "/private/tmp"
      "/private/var/tmp"
      "/private/var/folders"
    ];
in {
  imports = [
    ./oh-my-opencode-slim.nix
  ];

  catppuccin.opencode.enable = true;

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      permissions = lib.concatMap (resource: [
        {
          action = "external_directory";
          inherit resource;
          effect = "allow";
        }
        {
          action = "read";
          inherit resource;
          effect = "allow";
        }
        {
          action = "edit";
          inherit resource;
          effect = "ask";
        }
      ]) (lib.concatMap (path: [path "${path}/*"]) readRoots);
      plugin = [
        "opencode-atuin-history@1.0.2"
        "@dietrichgebert/ponytail@5.3.3"
        "@vectorize-io/hindsight-coding-agents@0.8.7"
      ];
    };
    cli = {
      plugin = [
        "opencode-terminal-progress@1.1.0"
      ];
      attention = {
        enabled = true;
      };
    };
  };
}
