_: {
  programs.nvf.settings.config.vim.languages = {
    enableFormat = true;
    enableTreesitter = true;
    enableExtraDiagnostics = true;

    nix.enable = true;
    markdown.enable = true;
    bash.enable = true;
    json.enable = true;
    ts.enable = true;
    python.enable = true;
    rust = {
      enable = true;
      extensions.crates-nvim.enable = true;
    };
    yaml.enable = true;
  };
}
