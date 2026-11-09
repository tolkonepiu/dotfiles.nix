{pkgs, ...}: {
  home.packages = with pkgs; [
    colima
    lima-full
    mole-cleaner
    paseo-desktop
  ];
}
