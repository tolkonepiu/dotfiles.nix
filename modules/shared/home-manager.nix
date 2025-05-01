{
  config,
  pkgs,
  lib,
  zdotdir,
  ...
}:

let
  name = "Pavel Popov";
  user = "chchmthrfckr";
  email = "me@popov.wtf";
in
{
  # Shared shell configuration
  zsh = {
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

    sessionVariables = {
      ZDOTDIR_SKIP_UPDATE = "1";
      ZSH_CONFIG_PATH = "${zdotdir}";
      ANTIDOTE_STATIC_FILE = "/tmp/tmp-hm-antidote-static-${zdotdir.rev}";
      ANTIDOTE_PATH = "${pkgs.antidote}/share/antidote/";
    };
  };

  git = {
    enable = true;
    ignores = [
      "*.swp"
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin ".DS_Store")
    ];
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
      pull.rebase = true;
    };
  };

  ssh = {
    enable = true;
    includes = [
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux "/home/${user}/.ssh/config_external")
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin "/Users/${user}/.ssh/config_external")
    ];
  };

  direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
