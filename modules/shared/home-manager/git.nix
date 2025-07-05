{
  pkgs,
  inputs,
  userConfig,
  ...
}:
{
  # Add catpuccin theme for delta
  home.file.".config/git/catppuccin.gitconfig" = {
    text = builtins.readFile (
      pkgs.runCommand "filtered-gitconfig" { } ''
        ${pkgs.gnused}/bin/sed 's/^\(\s*syntax-theme =.*\)$/# \1/' ${inputs.ctp-delta}/catppuccin.gitconfig > $out
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
