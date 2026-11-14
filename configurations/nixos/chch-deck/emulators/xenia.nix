{
  config,
  lib,
  ...
}: let
  user = config.jovian.steam.user;
  # Upstream exposes no finalPackage; Decky must use the configured HM launchers.
  xeniaPackages =
    builtins.filter
    (package: builtins.elem (package.name or "") ["xenia-canary-configured" "xenia-edge-configured"])
    config.home-manager.users.${user}.home.packages;
in {
  home-manager.users.${user}.programs = {
    xenia-canary.settings.Display.fullscreen = true;
    xenia-edge.settings.Display.fullscreen = true;
  };

  jovian.decky-loader.extraPackages = assert lib.assertMsg (builtins.length xeniaPackages == 2)
  "Expected two configured Xenia Home Manager packages; review upstream wrapper names and enabled modules"; xeniaPackages;
}
