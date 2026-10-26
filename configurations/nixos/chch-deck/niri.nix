{
  config,
  pkgs,
  ...
}: let
  actions = config.lib.niri.actions;
  niri = "${config.programs.niri.package}/bin/niri";
  powerOnMonitors = "${niri} msg action power-on-monitors";
in {
  # Gaming Mode also uses graphical-session.target. Desktop-only services must
  # follow niri itself, not every graphical session started by Jovian.
  wayland.systemd.target = "niri.service";

  # Use Wayland idle notifications so applications can inhibit desktop idling.
  services.swayidle = {
    enable = true;
    systemdTargets = [config.wayland.systemd.target];
    timeouts = [
      {
        timeout = 300;
        command = "${niri} msg action power-off-monitors";
        resumeCommand = powerOnMonitors;
      }
      {
        timeout = 900;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
    events.after-resume = powerOnMonitors;
  };
  # Home Manager supplies PartOf/WantedBy; also stop if Niri disappears.
  systemd.user.services.swayidle.Unit.BindsTo = [config.wayland.systemd.target];

  programs.niri.settings = {
    # Start the desktop client only in Niri, using NixOS's extest-enabled Steam.
    spawn-at-startup = [
      {command = ["/run/current-system/sw/bin/steam" "-silent"];}
    ];

    outputs."eDP-1" = {
      scale = 1;
      # Matches `niri msg output eDP-1 transform normal`.
      transform.rotation = 0;
    };
    input.touch.map-to-output = "eDP-1";

    binds = with actions; {
      "Mod+Escape".action = close-window;
      "Mod+Left".action = focus-column-left;
      "Mod+Right".action = focus-column-right;
      "Mod+Up".action = focus-workspace-up;
      "Mod+Down".action = focus-workspace-down;
      "Mod+Shift+Left".action = move-column-left;
      "Mod+Shift+Right".action = move-column-right;
      "Mod+Shift+Up".action = move-workspace-up;
      "Mod+Shift+Down".action = move-workspace-down;
    };
  };
}
