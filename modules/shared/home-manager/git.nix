{userConfig, ...}: {
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
