{
  home.sessionVariables.OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS = true;

  xdg.configFile."opencode/oh-my-opencode-slim.json" = {
    force = true;
    text = builtins.toJSON {
      "$schema" = "https://unpkg.com/oh-my-opencode-slim@latest/oh-my-opencode-slim.schema.json";

      autoUpdate = false;
      showStartupToast = false;

      preset = "main";

      presets = {
        main = {
          orchestrator = {
            model = "openai/gpt-5.5";
            variant = "medium";
            skills = ["*"];
            mcps = [
              "*"
              "!context7"
            ];
          };

          oracle = {
            model = "openai/gpt-5.5";
            variant = "high";
            skills = [
              "refactor-plan"
              "simplify"
            ];
            mcps = [];
          };

          librarian = {
            model = "openai/gpt-5.4-mini";
            variant = "low";
            skills = [];
            mcps = [
              "websearch"
              "context7"
              "gh_grep"
              "github"
            ];
          };

          explorer = {
            model = "openai/gpt-5.4-mini";
            variant = "low";
            skills = ["context-map"];
            mcps = [];
          };

          designer = {
            model = "openai/gpt-5.5";
            variant = "medium";
            skills = [
              "composition-patterns"
              "react-best-practices"
              "react-view-transitions"
              "web-design-guidelines"
              "web-design-reviewer"
            ];
            mcps = ["playwright"];
          };

          fixer = {
            model = "openai/gpt-5.5";
            variant = "low";
            skills = [
              "refactor"
              "git-commit"
            ];
            mcps = [];
          };
        };
      };

      # Use the shared OpenCode MCP config for Context7.
      # Disable only oh-my-opencode-slim's built-in registration.
      disabled_mcps = ["context7"];
    };
  };

  programs.opencode = {
    settings = {
      plugin = [
        "oh-my-opencode-slim@2.0.4"
      ];
      agent = {
        # Use oh-my-opencode-slim agents instead of OpenCode built-ins.
        build.disable = true;
        explore.disable = true;
        general.disable = true;
        plan.disable = true;
      };
    };
    tui = {
      plugin = [
        "oh-my-opencode-slim@2.0.4"
      ];
    };
  };
}
