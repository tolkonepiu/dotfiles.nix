{
  # oh-my-openagent config
  # Primary models use native OpenAI models and GitHub Copilot models.
  # OpenAI is the default primary provider for most agents/categories.
  # GitHub Copilot models are used as fallbacks and for selected specialist agents.

  xdg.configFile."opencode/oh-my-opencode.jsonc".text =
    builtins.toJSON
    {
      "$schema" = "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json";

      agents = {
        sisyphus = {
          model = "openai/gpt-5.4";
          fallback_models = [
            "github-copilot/claude-opus-4.6"
          ];
          reasoningEffort = "high";
          textVerbosity = "medium";
        };

        explore = {
          model = "github-copilot/grok-code-fast-1";
          fallback_models = [
            "openai/gpt-5.4-mini"
          ];
        };

        oracle = {
          model = "openai/gpt-5.4";
          fallback_models = [
            "github-copilot/gpt-5.4"
          ];
          reasoningEffort = "high";
          textVerbosity = "medium";
        };

        librarian = {
          model = "github-copilot/gemini-3-flash-preview";
          fallback_models = [
            "openai/gpt-5.4-mini"
          ];
        };

        prometheus = {
          model = "openai/gpt-5.4";
          fallback_models = [
            "github-copilot/gpt-5.4"
          ];
          reasoningEffort = "high";
          textVerbosity = "medium";
        };

        metis = {
          model = "openai/gpt-5.4";
          fallback_models = [
            "github-copilot/gpt-5.4"
          ];
          reasoningEffort = "high";
          textVerbosity = "medium";
        };

        momus = {
          model = "openai/gpt-5.4";
          fallback_models = [
            "github-copilot/gpt-5.4"
          ];
          reasoningEffort = "xhigh";
          textVerbosity = "medium";
        };

        atlas = {
          model = "openai/gpt-5.4";
          fallback_models = [
            "github-copilot/claude-sonnet-4.6"
          ];
          reasoningEffort = "medium";
          textVerbosity = "medium";
        };

        hephaestus = {
          model = "openai/gpt-5.3-codex";
          fallback_models = [
            "github-copilot/gpt-5.3-codex"
          ];
          reasoningEffort = "medium";
          textVerbosity = "medium";
        };

        multimodal-looker = {
          model = "openai/gpt-5.4";
          fallback_models = [
            "github-copilot/gpt-5.4"
          ];
          reasoningEffort = "medium";
          textVerbosity = "medium";
        };
      };

      categories = {
        quick = {
          model = "openai/gpt-5.4-mini";
          fallback_models = [
            "github-copilot/gpt-5-mini"
          ];
        };

        deep = {
          model = "openai/gpt-5.3-codex";
          fallback_models = [
            "github-copilot/gpt-5.3-codex"
          ];
          reasoningEffort = "medium";
          textVerbosity = "medium";
        };

        ultrabrain = {
          model = "openai/gpt-5.3-codex";
          fallback_models = [
            "github-copilot/gpt-5.3-codex"
          ];
          reasoningEffort = "xhigh";
          textVerbosity = "medium";
        };

        unspecified-low = {
          model = "openai/gpt-5.4-mini";
          fallback_models = [
            "github-copilot/gpt-5.4-mini"
          ];
          reasoningEffort = "medium";
          textVerbosity = "medium";
        };

        unspecified-high = {
          model = "openai/gpt-5.4";
          fallback_models = [
            "github-copilot/gpt-5.4"
          ];
          reasoningEffort = "high";
          textVerbosity = "medium";
        };

        visual-engineering = {
          model = "openai/gpt-5.4";
          fallback_models = [
            "github-copilot/gemini-3.1-pro-preview"
          ];
        };

        writing = {
          model = "openai/gpt-5.4";
          fallback_models = [
            "github-copilot/gpt-5.4"
          ];
          reasoningEffort = "medium";
          textVerbosity = "high";
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
