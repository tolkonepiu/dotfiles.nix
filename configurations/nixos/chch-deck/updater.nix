{
  config,
  lib,
  pkgs,
  ...
}: let
  requestUpdate = pkgs.writeShellApplication {
    name = "steamdeck-request-update";
    runtimeInputs = [pkgs.systemd pkgs.coreutils];
    text = builtins.readFile ./updater/request-update.sh;
  };
in {
  nixpkgs.overlays = [
    (_: prev: {
      jovianPackages = prev.jovianPackages.overrideScope (_: prevJovian: {
        jovian-stubs = prevJovian.jovian-stubs.overrideAttrs (old: {
          # Replace only updater entrypoints; retain all other Jovian stubs.
          buildCommand =
            old.buildCommand
            + ''
              install -m 755 ${lib.getExe requestUpdate} "$out/bin/holo-update"
              install -m 755 ${lib.getExe requestUpdate} "$out/bin/steamos-polkit-helpers/steamos-update"
            '';
        });
      });
    })
  ];

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id === "org.freedesktop.systemd1.manage-units" &&
          action.lookup("unit") === "nixos-upgrade.service" &&
          action.lookup("verb") === "start" &&
          subject.active && subject.local &&
          subject.user === ${builtins.toJSON config.jovian.steam.user}) {
        return polkit.Result.YES;
      }
    });
  '';
}
