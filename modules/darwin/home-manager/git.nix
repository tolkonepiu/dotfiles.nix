{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}:

{
  # Extend with Darwin-specific settings
  programs.git.ignores = [
    ".DS_Store"
  ];
}
