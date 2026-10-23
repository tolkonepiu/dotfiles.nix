{
  config,
  lib,
  ...
}: {
  programs.alacritty.enable = true;

  wayland.windowManager.hyprland.settings.bind = [
    {
      _args = [
        "SUPER + RETURN"
        (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${lib.getExe config.programs.alacritty.package}")'')
      ];
    }
  ];
}
