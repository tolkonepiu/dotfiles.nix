{
  imports = [
    ./lsp.nix
    ./oh-my-openagent.nix
  ];

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      plugin = [
        "oh-my-openagent@3.17.3"
        "opencode-wakatime@1.3.0"
        "opencode-atuin-history@0.1.0"
        "opencode-terminal-progress@0.4.3"
      ];
    };
  };
}
