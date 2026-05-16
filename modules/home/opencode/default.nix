{
  imports = [
    ./lsp.nix
    ./oh-my-opencode-slim.nix
    ./tui.nix
  ];

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      plugin = [
        "oh-my-opencode-slim@1.1.1"
        "opencode-wakatime@1.3.8"
        "opencode-atuin-history@0.1.0"
        "opencode-terminal-progress@0.5.0"
      ];
    };
  };
}
