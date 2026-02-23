{flake, ...}: let
  inherit (flake) inputs;
  isMaximal = false;
in {
  imports = [
    inputs.nvf.homeManagerModules.default
  ];

  programs.nvf = {
    enable = true;
    settings = {
      imports = [(import (inputs.nvf + "/configuration.nix") isMaximal)];
    };
  };
}
