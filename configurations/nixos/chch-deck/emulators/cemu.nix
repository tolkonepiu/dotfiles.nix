{pkgs, ...}: {
  environment.systemPackages = [pkgs.cemu];
  jovian.decky-loader.extraPackages = [pkgs.cemu];
}
