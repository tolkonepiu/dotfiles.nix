{
  imports = [
    ./oh-my-opencode.nix
  ];

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      plugin = [
        # renovate: datasource=npm depName=cc-safety-net
        "cc-safety-net@0.7.1"
        # renovate: datasource=npm depName=oh-my-opencode
        "oh-my-opencode@3.11.2"
        # renovate: datasource=npm depName=opencode-wakatime
        "opencode-wakatime@1.3.0"
      ];
    };
  };
}
