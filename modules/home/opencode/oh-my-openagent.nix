{
  # Disable oh-my-openagent telemetry
  home.sessionVariables.OMO_SEND_ANONYMOUS_TELEMETRY = "0";

  xdg.configFile."opencode/oh-my-openagent.jsonc" = {
    force = true;
    text = builtins.toJSON {
      # oh-my-openagent config
      # Models are aligned with upstream role defaults using the providers currently
      # available in local `opencode models` (GitHub Copilot, OpenAI).
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
          model = "github-copilot/gemini-3-flash-preview";
        };

        prometheus = {
          model = "github-copilot/claude-sonnet-4.6";
          variant = "max";
        };

        metis = {
          model = "github-copilot/claude-sonnet-4.6";
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
          model = "openai/gpt-5.3-codex";
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
          model = "openai/gpt-5.3-codex";
          variant = "high";
        };

        quick = {
          model = "github-copilot/claude-haiku-4.5";
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
  };
}
