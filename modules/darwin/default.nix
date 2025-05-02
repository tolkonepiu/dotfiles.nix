{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./home-manager.nix
    ./dock
  ];
}
