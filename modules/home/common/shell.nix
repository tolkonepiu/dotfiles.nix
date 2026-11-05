{
  lib,
  pkgs,
  flake,
  config,
  ...
}: let
  inherit (flake) inputs;
  antidoteHome = "${config.xdg.dataHome}/antidote";
in {
  programs.zsh = {
    enable = true;
    enableCompletion = false;
    dotDir = "${config.xdg.configHome}/zsh";
    initContent = lib.mkBefore ''
      mkdir -p -- "${antidoteHome}"
      # Source zdotdir configuration from https://github.com/tolkonepiu/zdotdir
      source "${inputs.zdotdir}/.zshrc"
    '';
    envExtra = ''
      # Source zdotdir env from https://github.com/tolkonepiu/zdotdir
      source "${inputs.zdotdir}/.zshenv"
    '';

    sessionVariables = {
      ZSH_CONFIG_PATH = "${inputs.zdotdir}";
      ANTIDOTE_BUNDLE_FILE = "${inputs.zdotdir}/.zsh_plugins.txt";
      ANTIDOTE_HOME = antidoteHome;
      ANTIDOTE_STATIC_FILE = "${antidoteHome}/antidote-static-${inputs.zdotdir.rev}.zsh";
      ANTIDOTE_PATH = "${pkgs.antidote}/share/antidote/";
    };
  };
}
