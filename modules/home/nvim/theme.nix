_: {
  programs.nvf.settings.config.vim = {
    theme = {
      enable = true;
      name = "catppuccin";
      style = "mocha";
      transparent = false;
    };
    statusline = {
      lualine = {
        enable = true;
        theme = "auto";
      };
    };
    filetree = {
      neo-tree = {
        enable = true;
      };
    };
  };
}
