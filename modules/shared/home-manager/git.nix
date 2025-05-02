{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}:

{
  programs.git = {
    enable = true;
    ignores = [
      "*.swp"
    ];
    userName = userConfig.name;
    userEmail = userConfig.email;
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
}
