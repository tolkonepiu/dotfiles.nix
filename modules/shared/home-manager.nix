{
  config,
  pkgs,
  lib,
  zdotdir,
  userConfig,
  ...
}:

# Import all modularized configurations
import ./home-manager/default.nix {
  inherit config pkgs lib zdotdir userConfig;
}
