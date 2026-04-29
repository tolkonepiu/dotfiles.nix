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
      oh-my-opencode-slim = {
        path = inputs.oh-my-opencode-slim;
        subdir = "src/skills";
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
      "refactor-plan"
      "refactor"
      "web-design-reviewer"
      # Vercel Agent Skills
      # See: https://github.com/vercel-labs/agent-skills/
      "composition-patterns"
      "react-best-practices"
      "react-view-transitions"
      "web-design-guidelines"
      # oh-my-opencode-slim
      # See: https://github.com/alvinunreal/oh-my-opencode-slim/blob/master/docs/skills.md
      "codemap"
      "simplify"
    ];
    targets.agents.enable = true;
  };
}
