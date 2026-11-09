{
  flake,
  pkgs,
  ...
}: {
  imports = [flake.inputs.stylix.homeModules.stylix];

  catppuccin.autoEnable = true;

  stylix = {
    enable = true;
    autoEnable = false;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  };
}
