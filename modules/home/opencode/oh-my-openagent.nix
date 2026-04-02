{
  # oh-my-openagent config
  # Models are aligned with upstream role defaults using the providers currently
  # available in local `opencode models` (GitHub Copilot, OpenAI).
  # OmO's built-in fallback chains still handle runtime resolution when the
  # preferred configured model is unavailable.

  xdg.configFile."opencode/oh-my-openagent.jsonc".text =
    builtins.toJSON
    {
      "$schema" = "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json";

      agents = {
        sisyphus = {
          model = "openai/gpt-5.4";
          variant = "medium";
        };

        hephaestus = {
          model = "openai/gpt-5.4";
          variant = "medium";
        };

        oracle = {
          model = "openai/gpt-5.4";
          variant = "high";
        };

        explore = {
          model = "github-copilot/gpt-5-mini";
        };

        prometheus = {
          model = "github-copilot/claude-opus-4.6";
          variant = "max";
        };

        metis = {
          model = "github-copilot/claude-opus-4.6";
          variant = "max";
        };

        momus = {
          model = "openai/gpt-5.4";
          variant = "xhigh";
        };

        atlas = {
          model = "github-copilot/claude-sonnet-4.6";
        };

        multimodal-looker = {
          model = "openai/gpt-5.4";
          variant = "medium";
        };

        sisyphus-junior = {
          model = "github-copilot/claude-sonnet-4.6";
        };

        librarian = {
          model = "github-copilot/gemini-3-flash-preview";
        };
      };

      categories = {
        visual-engineering = {
          model = "github-copilot/gemini-3.1-pro-preview";
          variant = "high";
        };

        ultrabrain = {
          model = "openai/gpt-5.4";
          variant = "xhigh";
        };

        deep = {
          model = "openai/gpt-5.3-codex";
          variant = "medium";
        };

        artistry = {
          model = "github-copilot/gemini-3.1-pro-preview";
          variant = "high";
        };

        quick = {
          model = "github-copilot/gpt-5.4-mini";
        };

        unspecified-low = {
          model = "github-copilot/claude-sonnet-4.6";
        };

        unspecified-high = {
          model = "github-copilot/claude-sonnet-4.6";
        };

        writing = {
          model = "github-copilot/gemini-3-flash-preview";
        };
      };

      experimental = {
        aggressive_truncation = true;
      };

      tmux = {
        enabled = false;
      };
    };
}
