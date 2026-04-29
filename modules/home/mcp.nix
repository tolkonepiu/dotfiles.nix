{flake, ...}: let
  inherit (flake) inputs;
in {
  imports = [
    inputs.mcp-servers-nix.homeManagerModules.default
  ];

  programs.mcp.enable = true;

  mcp-servers.programs = {
    git.enable = true;
    context7.enable = true;
    playwright = {
      enable = true;
      args = ["--headless"];
    };
    github = {
      enable = true;
      # Requires `gh auth login` so `gh auth token` can return a token.
      passwordCommand = {
        GITHUB_PERSONAL_ACCESS_TOKEN = ["gh" "auth" "token"];
      };
    };
  };
}
