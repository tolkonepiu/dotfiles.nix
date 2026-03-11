{
  imports = [
    ./oh-my-opencode.nix
  ];

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      plugin = [
        # renovate: datasource=npm depName=oh-my-opencode
        "oh-my-opencode@3.11.2"
      ];
    };
  };
}
