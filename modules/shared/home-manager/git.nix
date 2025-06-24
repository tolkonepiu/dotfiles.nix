{
  userConfig,
  pkgs,
  ...
}:

let
  ctp-delta = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "delta";
    rev = "e9e21cffd98787f1b59e6f6e42db599f9b8ab399";
    hash = "sha256-04po0A7bVMsmYdJcKL6oL39RlMLij1lRKvWl5AUXJ7Q=";
  };
in
{
  # Add catpuccin theme for delta
  home.file.".config/git/catppuccin.gitconfig" = {
    text = builtins.readFile (
      pkgs.runCommand "filtered-gitconfig" { } ''
        ${pkgs.gnused}/bin/sed 's/^\(\s*syntax-theme =.*\)$/# \1/' ${ctp-delta}/catppuccin.gitconfig > $out
      ''
    );
  };

  programs.git = {
    enable = true;

    userName = userConfig.name;
    userEmail = userConfig.email;

    ignores = [
      "*.swp"
    ];

    lfs = {
      enable = true;
    };

    signing = {
      format = "openpgp";
      signByDefault = true;
    };

    includes = [
      { path = "catppuccin.gitconfig"; }
    ];

    delta = {
      enable = true;
      options = {
        diff-so-fancy = true;
        line-numbers = true;
        side-by-side = false;
        features = "catppuccin-mocha";
        catppuccin-mocha = {
          syntax-theme = "base16-stylix";
        };
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
