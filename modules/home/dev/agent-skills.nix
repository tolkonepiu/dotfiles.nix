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
      vercel-skills = {
        path = inputs.vercel-skills;
        subdir = "skills";
      };
    };
    skills.enable = [
      # Awesome GitHub Copilot
      # See: https://github.com/github/awesome-copilot/blob/main/docs/README.skills.md
      "agent-governance"
      "agentic-eval"
      "context-map"
      "create-agentsmd"
      "create-implementation-plan"
      "create-readme"
      "create-specification"
      "git-commit"
      "github-issues"
      "refactor-plan"
      "refactor"
      "web-design-reviewer"
      # Vercel Agent Skills
      # See: https://github.com/vercel-labs/agent-skills/
      "composition-patterns"
      "react-best-practices"
      "react-view-transitions"
      "web-design-guidelines"
    ];
    targets.agents.enable = true;
  };
}
