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
        # renovate: datasource=npm depName=oh-my-opencode
        "oh-my-openagent@3.16.0"
        # renovate: datasource=npm depName=opencode-wakatime
        "opencode-wakatime@1.3.0"
        # renovate: datasource=npm depName=opencode-atuin-history
        "opencode-atuin-history@0.1.0"
        # renovate: datasource=npm depName=opencode-terminal-progress
        "opencode-terminal-progress@0.4.3"
      ];
    };
  };
}
