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
        "opencode-wakatime@1.4.0"
        "opencode-atuin-history@1.0.1"
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
