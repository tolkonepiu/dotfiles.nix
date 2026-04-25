{
  imports = [
    ./lsp.nix
    ./oh-my-openagent.nix
    ./tui.nix
  ];

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      plugin = [
        "oh-my-openagent@3.17.5"
        "opencode-wakatime@1.3.1"
        "opencode-atuin-history@0.1.0"
        "opencode-terminal-progress@0.5.0"
        "@honcho-ai/opencode-honcho@0.1.1"
      ];
    };
  };
}
