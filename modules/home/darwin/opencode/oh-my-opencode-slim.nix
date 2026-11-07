{
  home.sessionVariables = {
    OPENCODE_ENABLE_EXA = "1";
  };

  xdg.configFile."opencode/oh-my-opencode-slim.json" = {
    force = true;
    text = builtins.toJSON {
      "$schema" = "https://unpkg.com/oh-my-opencode-slim@latest/oh-my-opencode-slim.schema.json";

      autoUpdate = false;

      preset = "main";

      presets = {
        main = {
          orchestrator = {
            model = "openai/gpt-6.1-sol";
            variant = "high";
            skills = ["*"];
            mcps = [
              "*"
              "!context7"
            ];
          };

          oracle = {
            model = "openai/gpt-6-astra";
            variant = "xhigh";
            skills = [
              "refactor-plan"
              "simplify"
            ];
            mcps = [];
          };

          explorer = {
            model = "openai/gpt-6-luna-fast";
            variant = "low";
            skills = ["context-map"];
            mcps = [
              "context7"
              "gh_grep"
              "github"
            ];
          };

          designer = {
            model = "openai/gpt-6.1-terra";
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
            model = "openai/gpt-6.1-sol";
            variant = "medium";
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
        "oh-my-opencode-slim@3.0.7"
      ];
      agent = {
        # Use oh-my-opencode-slim agents instead of OpenCode built-ins.
        build.disable = true;
        explore.disable = true;
        explorer.disable = false;
        general.disable = true;
        plan.disable = true;
      };
    };
    cli = {
      plugin = [
        "oh-my-opencode-slim@3.0.7"
      ];
    };
  };
}
