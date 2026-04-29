{
  xdg.configFile."opencode/oh-my-opencode-slim.json" = {
    force = true;
    text = builtins.toJSON {
      "$schema" = "https://unpkg.com/oh-my-opencode-slim@latest/oh-my-opencode-slim.schema.json";

      preset = "openai";

      presets = {
        openai = {
          orchestrator = {
            model = "openai/gpt-5.5";
            skills = ["*"];
            mcps = [
              "*"
              "!context7"
            ];
          };

          oracle = {
            model = "openai/gpt-5.5";
            variant = "high";
            skills = ["simplify"];
            mcps = [];
          };

          librarian = {
            model = "openai/gpt-5.4-mini";
            variant = "low";
            skills = [];
            mcps = [
              "websearch"
              "context7"
              "grep_app"
            ];
          };

          explorer = {
            model = "openai/gpt-5.4-mini";
            variant = "low";
            skills = [];
            mcps = [];
          };

          designer = {
            model = "openai/gpt-5.4-mini";
            variant = "medium";
            skills = [];
            mcps = [];
          };

          fixer = {
            model = "openai/gpt-5.4-mini";
            variant = "low";
            skills = [];
            mcps = [];
          };
        };
      };
    };
  };
}
