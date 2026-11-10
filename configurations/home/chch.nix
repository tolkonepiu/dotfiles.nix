{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    self.homeModules.base
  ];

  me = {
    username = "chch";
    name = "Pavel Popov";
    email = "me@popov.wtf";
    authorizedKeys = [
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBFvab4tDewcRCKZeEi0jZ2PfhF1PPZ8TfZJChS29qJDMAHzA+EqrNrYBOBfO1WayyvzbMocjWLhQcwIjDmN7mE="
    ];
    atuinServer = "https://atuin.chchlabs.dev";
  };

  home.stateVersion = "26.11";
}
