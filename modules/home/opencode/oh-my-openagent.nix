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
          model = "github-copilot/claude-opus-4.6";
          variant = "max";
        };

        explore = {
          model = "github-copilot/grok-code-fast-1";
        };

        oracle = {
          model = "openai/gpt-5.4";
          variant = "high";
        };

        librarian = {
          model = "github-copilot/gemini-3-flash-preview";
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

        hephaestus = {
          model = "openai/gpt-5.4";
          variant = "medium";
        };

        multimodal-looker = {
          model = "openai/gpt-5.4";
          variant = "medium";
        };
      };

      categories = {
        quick = {
          model = "github-copilot/gpt-5.4-mini";
        };

        deep = {
          model = "openai/gpt-5.4";
          variant = "medium";
        };

        ultrabrain = {
          model = "openai/gpt-5.4";
          variant = "xhigh";
        };

        artistry = {
          model = "github-copilot/gemini-3.1-pro-preview";
          variant = "high";
        };

        unspecified-low = {
          model = "github-copilot/claude-sonnet-4.6";
        };

        unspecified-high = {
          model = "github-copilot/claude-opus-4.6";
          variant = "max";
        };

        visual-engineering = {
          model = "github-copilot/gemini-3.1-pro-preview";
          variant = "high";
        };

        writing = {
          model = "github-copilot/gemini-3-flash-preview";
        };
      };

      runtime_fallback = {
        enabled = true;
        retry_on_errors = [400 429 503 529];
        max_fallback_attempts = 3;
        cooldown_seconds = 15;
        timeout_seconds = 8;
        notify_on_fallback = true;
      };

      experimental = {
        aggressive_truncation = true;
      };

      tmux = {
        enabled = false;
      };
    };
}
