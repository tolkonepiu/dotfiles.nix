{
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv = {
      enable = true;
    };
    config.global = {
      # Make direnv messages less verbose
      hide_env_diff = true;
    };
  };
}
