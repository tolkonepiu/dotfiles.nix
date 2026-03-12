{
  xdg.configFile."opencode/oh-my-opencode.jsonc".text =
    builtins.toJSON
    {
      "$schema" = "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json";

      agents = {
        sisyphus = {
          model = "github-copilot/claude-opus-41";
        };
        explore = {
          model = "github-copilot/grok-code-fast-1";
        };
        oracle = {
          model = "openai/gpt-5.4";
        };
        librarian = {
          model = "github-copilot/gemini-3-flash-preview";
        };
      };

      categories = {
        quick = {model = "opencode/gpt-5-nano";};
        unspecified-low = {model = "github-copilot/claude-sonnet-4.6";};
        unspecified-high = {model = "openai/gpt-5.4";};
        visual-engineering = {model = "github-copilot/gemini-3.1-pro-preview";};
        writing = {model = "github-copilot/gemini-3-flash-preview";};
      };

      experimental = {
        aggressive_truncation = true;
      };

      tmux = {
        enabled = false;
      };
    };
}
