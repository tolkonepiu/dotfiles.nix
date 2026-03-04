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
  };
}
