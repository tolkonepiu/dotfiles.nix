{flake, ...}: {
  imports = [flake.inputs.nix-emulators.homeManagerModules.eden];

  programs.eden.enable = true;
}
