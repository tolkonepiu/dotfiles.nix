{
  imports = [
    ./oh-my-opencode.nix
  ];

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      plugin = ["oh-my-opencode"];
    };
  };
}
