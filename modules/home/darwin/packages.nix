{pkgs, ...}: {
  home.packages = with pkgs; [
    # Virtualization
    colima
    lima-full

    # Tools
    mole-cleaner
  ];
}
