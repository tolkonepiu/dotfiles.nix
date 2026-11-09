{flake, ...}: let
  inherit (flake) inputs;
in {
  imports = [
    inputs.nvf.homeManagerModules.default
    ./theme.nix
  ];

  home.sessionVariables.EDITOR = "nvim";

  programs.nvf = {
    enable = true;
    settings = {
      config.vim = {
        viAlias = true;
        vimAlias = true;

        # vim.opts and vim.options are aliased
        opts.expandtab = true;
      };
    };
  };
}
