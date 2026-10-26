{
  config,
  flake,
  lib,
  pkgs,
  ...
}: let
  upstream =
    if config.system.autoUpgrade.flake == null
    then null
    else builtins.match "github:([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+)/([^#]+)#([^#]+)" config.system.autoUpgrade.flake;
  updater = pkgs.writeShellApplication {
    name = "nixos-update";
    runtimeInputs = [pkgs.systemd pkgs.coreutils pkgs.gitMinimal pkgs.jq];
    runtimeEnv = lib.optionalAttrs (upstream != null) {
      UPDATE_REPOSITORY = "https://github.com/${builtins.elemAt upstream 0}/${builtins.elemAt upstream 1}.git";
      UPDATE_REF = "refs/heads/${builtins.elemAt upstream 2}";
    };
    text = builtins.readFile ./auto-upgrade/nixos-update.sh;
  };
in {
  system.autoUpgrade = {
    enable = lib.mkDefault true;
    flake = lib.mkDefault "github:tolkonepiu/dotfiles.nix/main#${config.networking.hostName}";
    operation = lib.mkDefault "boot";
    upgrade = lib.mkDefault false;
    allowReboot = lib.mkDefault false;
    dates = lib.mkDefault "04:40";
    randomizedDelaySec = lib.mkDefault "5min";
    persistent = lib.mkDefault true;
    flags = ["--no-update-lock-file" "--no-write-lock-file"];
  };

  assertions = [
    {
      assertion = upstream != null;
      message = "nixos-update requires system.autoUpgrade.flake = github:OWNER/REPO/BRANCH#HOST.";
    }
  ];
  system.configurationRevision = lib.mkDefault (flake.inputs.self.rev or flake.inputs.self.dirtyRev or null);
  environment.systemPackages = [updater];
  security.polkit = {
    enable = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id === "org.freedesktop.systemd1.manage-units" &&
            action.lookup("unit") === "nixos-upgrade.service" &&
            action.lookup("verb") === "start" &&
            subject.active && subject.local && subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
