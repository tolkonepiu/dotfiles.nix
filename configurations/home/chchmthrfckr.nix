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
  };

  home.stateVersion = "25.11";
}
