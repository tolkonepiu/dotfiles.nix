{
  config,
  pkgs,
  lib,
  ...
}:

let
  name = "Pavel Popov";
  email = "me@popov.wtf";
in
{
  programs.git = {
    enable = true;
    ignores = [
      "*.swp"
      # Removed Darwin-specific .DS_Store ignore
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
}
