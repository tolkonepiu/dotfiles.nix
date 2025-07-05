{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  programs.zsh = {
    enable = true;
    enableCompletion = false;
    dotDir = ".config/zsh";
    initContent = lib.mkBefore ''
      # Source zdotdir configuration from https://github.com/tolkonepiu/zdotdir
      source "${inputs.zdotdir}/.zshrc"
    '';
    envExtra = ''
      # Source zdotdir env from https://github.com/tolkonepiu/zdotdir
      source "${inputs.zdotdir}/.zshenv"
    '';

    shellAliases = {
      pass = "gopass";
    };

    sessionVariables = {
      EDITOR = "vim";
      ZDOTDIR_SKIP_UPDATE = "1";
      ZSH_CONFIG_PATH = "${inputs.zdotdir}";
      ANTIDOTE_STATIC_FILE = "/tmp/tmp-hm-antidote-static-${inputs.zdotdir.rev}";
      ANTIDOTE_PATH = "${pkgs.antidote}/share/antidote/";
    };
  };
}
