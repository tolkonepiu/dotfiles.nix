# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/gh/ghostty/package.nix#L194-L195
{pkgs, ...}: {
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    settings = {
      font-family = "MesloLGS NF";
      font-size = 18;
    };
  };
}
