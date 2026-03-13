{flake, ...}: let
  inherit (flake) inputs;
in {
  imports = [
    inputs.agent-skills.homeManagerModules.default
  ];

  programs.agent-skills = {
    enable = true;
    sources = {
      awesome-copilot = {
        path = inputs.awesome-copilot;
        subdir = "skills";
      };
    };
    skills.enable = [
      "context-map"
      "create-agentsmd"
      "create-implementation-plan"
      "create-readme"
      "create-specification"
      "gh-cli"
      "git-commit"
      "github-issues"
    ];
    targets.agents.enable = true;
  };
}
