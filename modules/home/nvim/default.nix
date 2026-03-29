{flake, ...}: let
  inherit (flake) inputs;
in {
  imports = [
    inputs.nvf.homeManagerModules.default
    ./languages.nix
    ./theme.nix
  ];

  programs.nvf = {
    enable = true;
    settings = {
      config.vim = {
        viAlias = true;
        vimAlias = true;

        # vim.opts and vim.options are aliased
        opts.expandtab = true;

        lsp = {
          enable = true;
          formatOnSave = true;
        };
      };
    };
  };
}
