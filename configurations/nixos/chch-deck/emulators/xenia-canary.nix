{pkgs, ...}: {
  environment.systemPackages = [pkgs.xenia-canary];
  jovian.decky-loader.extraPackages = [pkgs.xenia-canary];
}
