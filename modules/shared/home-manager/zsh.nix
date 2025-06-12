{
  config,
  pkgs,
  lib,
  zdotdir,
  ...
}:

{
  programs.zsh = {
    enable = true;
    enableCompletion = false;
    dotDir = ".config/zsh";
    initContent = lib.mkBefore ''
      # Source zdotdir configuration from https://github.com/tolkonepiu/zdotdir
      source "${zdotdir}/.zshrc"
    '';
    envExtra = ''
      # Source zdotdir env from https://github.com/tolkonepiu/zdotdir
      source "${zdotdir}/.zshenv"
    '';

    shellAliases = {
      pass = "gopass";
    };

    sessionVariables = {
      EDITOR = "vim";
      ZDOTDIR_SKIP_UPDATE = "1";
      ZSH_CONFIG_PATH = "${zdotdir}";
      ANTIDOTE_STATIC_FILE = "/tmp/tmp-hm-antidote-static-${zdotdir.rev}";
      ANTIDOTE_PATH = "${pkgs.antidote}/share/antidote/";
    };
  };
}
