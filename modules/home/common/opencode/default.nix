{
  config,
  lib,
  ...
}: {
  imports = [
    ./lsp.nix
    ./oh-my-opencode-slim.nix
  ];

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      plugin = [
        "opencode-wakatime@1.4.0"
        "opencode-atuin-history@1.0.1"
      ];
    };
    tui = {
      plugin = [
        "opencode-terminal-progress@1.1.0"
      ];
      attention = {
        enabled = true;
      };
    };
  };

  # TODO: Remove once Home Manager supports OpenCode CLI plugin configuration
  home.activation.removeOpenCodeCliConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run rm -f -- "${config.xdg.configHome}/opencode/cli.json"
  '';
}
