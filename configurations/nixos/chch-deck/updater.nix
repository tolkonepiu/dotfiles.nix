{
  config,
  flake,
  lib,
  pkgs,
  ...
}: let
  upstream = builtins.match "github:([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+)/([^#]+)#([^#]+)" config.system.autoUpgrade.flake;
  requestUpdate = pkgs.writeShellApplication {
    name = "steamdeck-request-update";
    runtimeInputs = [pkgs.systemd pkgs.coreutils pkgs.gitMinimal];
    runtimeEnv = lib.optionalAttrs (upstream != null) {
      UPDATE_REPOSITORY = "https://github.com/${builtins.elemAt upstream 0}/${builtins.elemAt upstream 1}.git";
      UPDATE_REF = "refs/heads/${builtins.elemAt upstream 2}";
    };
    text = builtins.readFile ./updater/request-update.sh;
  };
in {
  assertions = [
    {
      assertion = upstream != null;
      message = "Steam Deck updater requires system.autoUpgrade.flake = github:OWNER/REPO/BRANCH#HOST.";
    }
  ];
  system.configurationRevision = lib.mkDefault (flake.inputs.self.rev or flake.inputs.self.dirtyRev or null);

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
