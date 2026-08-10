{
  imports = [
    ./lsp.nix
    ./oh-my-opencode-slim.nix
  ];

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      plugin = [
        "opencode-wakatime@1.3.9"
        "opencode-atuin-history@0.1.0"
        "opencode-terminal-progress@0.5.1"
      ];
    };
    tui = {
      attention = {
        enabled = true;
      };
    };
  };
}
