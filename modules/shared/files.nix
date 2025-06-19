{
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
  ".config/git/catppuccin.gitconfig" = {
    text = builtins.readFile "${ctp-delta}/catppuccin.gitconfig";
  };

}
