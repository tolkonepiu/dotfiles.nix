{pkgs, ...}: {
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;
    settings = {
      font-family = "MesloLGS NF";
      font-size = 18;
    };
  };
}
