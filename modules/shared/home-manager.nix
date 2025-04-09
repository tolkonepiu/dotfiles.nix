{ config, pkgs, lib, zdotdir, ... }:

let name = "Pavel Popov";
    user = "chchmthrfckr";
    email = "me@popov.wtf";
 in
{
  # Shared shell configuration
  zsh = {
    enable = true;
    enableCompletion = false;
    dotDir = ".config/zsh";
    initExtraFirst = ''
      # Source zdotdir configuration from https://github.com/tolkonepiu/zdotdir
      source "${zdotdir}/.zshrc"
    '';
    envExtra = ''
      export ZDOTDIR_SKIP_UPDATE=1
      export ZSH_CONFIG_PATH="${zdotdir}"
      export ANTIDOTE_PATH="${pkgs.antidote}/share/antidote/"

      # Source zdotdir env from https://github.com/tolkonepiu/zdotdir
      source "${zdotdir}/.zshenv"
    '';
  };

  git = {
    enable = true;
    ignores = [ "*.swp" ];
    userName = name;
    userEmail = email;
    lfs = {
      enable = true;
    };
    signing = {
      format = "openpgp";
      signByDefault = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      core = {
	    editor = "vim";
        autocrlf = "input";
      };
      pull.rebase = false;
    };
  };

  ssh = {
    enable = true;
    includes = [
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
        "/home/${user}/.ssh/config_external"
      )
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        "/Users/${user}/.ssh/config_external"
      )
    ];
  };
}
