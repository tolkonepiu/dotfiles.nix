{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  programs.git = {
    enable = true;

    userName = config.me.fullname;
    userEmail = config.me.email;

    ignores = lib.mkMerge [
      [
        ".direnv"
        ".venv"
        "*.log"
        "*.tmp"
        "*.swp"
      ]
      # Extend with Darwin-specific settings
      (lib.mkIf isDarwin [
        ".DS_Store"
      ])
    ];

    lfs = {
      enable = true;
    };

    signing = {
      format = "openpgp";
      signByDefault = true;
    };

    delta = {
      enable = true;
      options = {
        diff-so-fancy = true;
        line-numbers = true;
        side-by-side = false;
      };
    };

    extraConfig = {
      init.defaultBranch = "main";
      core = {
        editor = "vim";
        autocrlf = "input";
      };
      pull.rebase = true;
      alias = {
        lg = "log --graph --pretty=tformat:'%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --decorate=full";
      };
    };
  };
}
