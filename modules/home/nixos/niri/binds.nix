{
  config,
  lib,
  ...
}: let
  actions = config.lib.niri.actions;
  noctalia = lib.getExe config.programs.noctalia.package;
  workspaceBinds = lib.listToAttrs (
    lib.concatMap (n: [
      {
        name = "Ctrl+Alt+${toString n}";
        value.action = actions.focus-workspace n;
      }
      {
        name = "Mod+Ctrl+Alt+${toString n}";
        value.action.move-window-to-workspace = [n];
      }
    ]) (lib.range 1 9)
  );
in {
  programs.niri.settings.binds = lib.mapAttrs (_: binding:
    binding // {action = lib.mkDefault binding.action;}) (
    (with actions; {
      # Applications.
      "Mod+Return".action = spawn (lib.getExe config.programs.alacritty.package);
      "Mod+Space".action = spawn noctalia "msg" "panel-toggle" "launcher";
      "Mod+Comma".action = spawn noctalia "msg" "settings-toggle";

      # Window management.
      "Mod+Q".action = close-window;
      "Mod+O".action = toggle-overview;
      "Mod+Shift+F".action = fullscreen-window;

      # Focus windows with Ctrl+Alt+H/J/K/L.
      "Ctrl+Alt+H".action = focus-column-left;
      "Ctrl+Alt+J".action = focus-window-down;
      "Ctrl+Alt+K".action = focus-window-up;
      "Ctrl+Alt+L".action = focus-column-right;

      # Move windows with Super+Ctrl+Alt+H/J/K/L.
      "Mod+Ctrl+Alt+H".action = move-column-left;
      "Mod+Ctrl+Alt+J".action = move-window-down;
      "Mod+Ctrl+Alt+K".action = move-window-up;
      "Mod+Ctrl+Alt+L".action = move-column-right;

      # First / last column.
      "Ctrl+Alt+A".action = focus-column-first;
      "Ctrl+Alt+Semicolon".action = focus-column-last;
      "Mod+Ctrl+Alt+A".action = move-column-to-first;
      "Mod+Ctrl+Alt+Semicolon".action = move-column-to-last;

      # Virtual workspaces.
      "Ctrl+Alt+U".action = focus-workspace-down;
      "Ctrl+Alt+I".action = focus-workspace-up;
      "Mod+Ctrl+Alt+U".action = move-window-to-workspace-down;
      "Mod+Ctrl+Alt+I".action = move-window-to-workspace-up;

      # Layout and resizing.
      "Ctrl+Alt+R".action = switch-preset-column-width;
      "Mod+Ctrl+Alt+R".action = switch-preset-column-width-back;
      "Ctrl+Alt+F".action = maximize-column;
      "Ctrl+Alt+C".action = center-column;
      "Ctrl+Alt+V".action = toggle-window-floating;

      # Stacking.
      "Ctrl+Alt+BracketLeft".action = consume-or-expel-window-left;
      "Ctrl+Alt+BracketRight".action = expel-window-from-column;
      "Ctrl+Alt+E".action = reset-window-height;

      # Multi-display.
      "Ctrl+Alt+N".action = focus-monitor-next;
      "Mod+Ctrl+Alt+N".action = move-window-to-monitor-next;

      # Center the focused column back in the viewport.
      "Ctrl+Alt+S".action = center-column;

      # Session.
      "Mod+Shift+E".action = quit;

      # Noctalia audio.
      "XF86AudioRaiseVolume".action = spawn noctalia "msg" "volume-up";
      "XF86AudioLowerVolume".action = spawn noctalia "msg" "volume-down";
      "XF86AudioMute".action = spawn noctalia "msg" "volume-mute";

      # Noctalia brightness.
      "XF86MonBrightnessUp".action = spawn noctalia "msg" "brightness-up";
      "XF86MonBrightnessDown".action = spawn noctalia "msg" "brightness-down";
    })
    // workspaceBinds
  );
}
