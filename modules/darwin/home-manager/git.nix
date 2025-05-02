{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Extend with Darwin-specific settings
  programs.git.ignores = [
    ".DS_Store"
  ];
}
