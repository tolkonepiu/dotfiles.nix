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

    settings = {
      user = {
        inherit (config.me) fullname;
        inherit (config.me) email;
      };
      init.defaultBranch = "main";
      core = {
        editor = "vim";
        autocrlf = "input";
      };
      pull.rebase = true;
      alias = {
        lg = "log --graph --pretty=tformat:'%C(magenta)%h%Creset %C(blue)%d%Creset %C(white)%s %C(green)(%cr)%Creset %C(cyan)<%an>%Creset' --abbrev-commit --decorate=full";
      };
    };
  };
}
