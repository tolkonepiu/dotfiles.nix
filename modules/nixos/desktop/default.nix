{pkgs, ...}: {
  imports = [./niri.nix ./noctalia.nix];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];
}
