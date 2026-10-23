{
  flake,
  lib,
  pkgs,
  ...
}: let
  ambxst = flake.inputs.ambxst.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  home.packages = [ambxst];

  wayland.windowManager.hyprland.settings.on = [
    {
      _args = [
        "hyprland.start"
        (lib.generators.mkLuaInline ''
          function()
            hl.exec_cmd("${lib.getExe ambxst}")
          end
        '')
      ];
    }
  ];
}
