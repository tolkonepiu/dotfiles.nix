{config, ...}: {
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      server_url = config.me.atuinServer;
      search_mode = "prefix";
    };
  };
}
