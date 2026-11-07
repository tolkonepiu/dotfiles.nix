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
        "opencode-atuin-history@1.0.1"
        "@dietrichgebert/ponytail@5.3.3"
        "@vectorize-io/hindsight-coding-agents@0.8.6"
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
