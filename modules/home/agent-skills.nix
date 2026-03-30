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
      "gh-cli"
      "git-commit"
      "github-issues"
      "web-design-reviewer"
      # Vercel Agent Skills
      # See: https://github.com/vercel-labs/agent-skills/
      "web-design-guidelines"
      "react-best-practices"
      "composition-patterns"
    ];
    targets.agents.enable = true;
  };
}
