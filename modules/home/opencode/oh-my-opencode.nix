{
  xdg.configFile."opencode/oh-my-opencode.jsonc".text =
    builtins.toJSON
    {
      "$schema" = "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json";

      agents = {
        sisyphus = {
          model = "openai/gpt-5.4";
          reasoningEffort = "high";
          textVerbosity = "medium";
        };
        explore = {
          model = "github-copilot/grok-code-fast-1";
        };
        oracle = {
          model = "openai/gpt-5.4";
          reasoningEffort = "high";
          textVerbosity = "medium";
        };
        librarian = {
          model = "github-copilot/gemini-3-flash-preview";
        };
        prometheus = {
          model = "openai/gpt-5.4";
          reasoningEffort = "high";
          textVerbosity = "medium";
        };
        metis = {
          model = "openai/gpt-5.4";
          reasoningEffort = "high";
          textVerbosity = "medium";
        };
        momus = {
          model = "openai/gpt-5.4";
          reasoningEffort = "xhigh";
          textVerbosity = "medium";
        };
        atlas = {
          model = "openai/gpt-5.4";
          reasoningEffort = "medium";
          textVerbosity = "medium";
        };
        hephaestus = {
          model = "openai/gpt-5.3-codex";
          reasoningEffort = "medium";
          textVerbosity = "medium";
        };
        multimodal-looker = {
          model = "openai/gpt-5.4";
          reasoningEffort = "medium";
          textVerbosity = "medium";
        };
      };

      categories = {
        quick = {model = "opencode/gpt-5-nano";};
        deep = {
          model = "openai/gpt-5.3-codex";
          reasoningEffort = "medium";
          textVerbosity = "medium";
        };
        ultrabrain = {
          model = "openai/gpt-5.3-codex";
          reasoningEffort = "xhigh";
          textVerbosity = "medium";
        };
        unspecified-low = {
          model = "openai/gpt-5.4";
          reasoningEffort = "medium";
          textVerbosity = "medium";
        };
        unspecified-high = {
          model = "openai/gpt-5.4";
          reasoningEffort = "high";
          textVerbosity = "medium";
        };
        visual-engineering = {model = "github-copilot/gemini-3.1-pro-preview";};
        writing = {
          model = "openai/gpt-5.4";
          reasoningEffort = "medium";
          textVerbosity = "high";
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
