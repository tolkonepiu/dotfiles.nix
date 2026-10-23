{config, ...}: {
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      auto_sync = true;
      sync_address = config.me.atuinServer;
      filter_mode = "host";
      search_mode = "fuzzy";
      history_filter = [
        "^gopass($| )"
      ];
    };
  };
}
