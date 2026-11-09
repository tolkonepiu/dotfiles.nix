{
  imports = [
    ./languages.nix
  ];

  programs.nvf.settings.config.vim.lsp = {
    enable = true;
    formatOnSave = true;
  };
}
