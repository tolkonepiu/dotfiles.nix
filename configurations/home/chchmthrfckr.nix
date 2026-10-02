{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    self.homeModules.default
  ];

  me = {
    username = "chchmthrfckr";
    fullname = "Pavel Popov";
    email = "me@popov.wtf";
    atuinServer = "https://atuin.chchlabs.dev";
  };

  home.stateVersion = "26.11";
}
