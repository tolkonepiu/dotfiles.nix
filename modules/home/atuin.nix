{config, ...}: {
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      auto_sync = true;
      sync_address = config.me.atuinServer;
    };
  };
}
