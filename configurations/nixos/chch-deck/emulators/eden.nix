{
  config,
  flake,
  lib,
  pkgs,
  ...
}: let
  eden = flake.inputs.eden.packages.${pkgs.stdenv.hostPlatform.system}.zen2;
  user = config.jovian.steam.user;
  group = config.users.users.${user}.group;
  configHome = config.home-manager.users.${user}.xdg.configHome;
  configDir = "${configHome}/eden";

  # Eden v0.2.1 uses raw SDL joystick indices and clears GUID CRC bytes 2-3.
  # This is the first Steam Input virtual gamepad; device ordering may require
  # selecting the controller in Eden's GUI.
  sdl = suffix: "engine:sdl,port:0,guid:03000000de280000ff11000001000000,pad:0,${suffix}";
  motion = "engine:cemuhookudp,guid:0000000000000000000000007f000001,port:26760,pad:0,motion:0";
  playerControls = {
    type = 0;
    connected = true;
    vibration_enabled = true;
    vibration_strength = 100;
    button_a = sdl "button:1";
    button_b = sdl "button:0";
    button_x = sdl "button:3";
    button_y = sdl "button:2";
    button_l = sdl "button:4";
    button_r = sdl "button:5";
    button_lstick = sdl "button:9";
    button_rstick = sdl "button:10";
    button_minus = sdl "button:6";
    button_plus = sdl "button:7";
    button_dup = sdl "hat:0,direction:up";
    button_ddown = sdl "hat:0,direction:down";
    button_dleft = sdl "hat:0,direction:left";
    button_dright = sdl "hat:0,direction:right";
    button_zl = sdl "axis:2,threshold:0.5,invert:+";
    button_zr = sdl "axis:5,threshold:0.5,invert:+";
    lstick = sdl "axis_x:0,axis_y:1,offset_x:0,offset_y:0,invert_x:+,invert_y:+,deadzone:0.1,range:1";
    rstick = sdl "axis_x:3,axis_y:4,offset_x:0,offset_y:0,invert_x:+,invert_y:+,deadzone:0.1,range:1";
    # Explicitly unbound; keep the Steam guide key reserved for Steam.
    button_home = "[empty]";
    button_screenshot = "[empty]";
    button_slleft = "[empty]";
    button_srleft = "[empty]";
    button_slright = "[empty]";
    button_srright = "[empty]";
    motionleft = motion;
    motionright = motion;
  };
  # v0.2.1 ignores supplied values unless their literal \default flag is false.
  mkIni = controls:
    lib.generators.toINI {} {
      Controls = controls // lib.mapAttrs' (name: _: lib.nameValuePair "${name}\\default" false) controls;
    };
  profileSeed = pkgs.writeText "eden-SteamDeck.ini" (mkIni playerControls);
  globalSeed = pkgs.writeText "eden-qt-config.ini" (mkIni (
    lib.mapAttrs' (name: value: lib.nameValuePair "player_0_${name}" value) playerControls
    // {
      enable_udp_controller = true;
      udp_input_servers = "127.0.0.1:26760";
      motion_enabled = true;
      vibration_enabled = true;
      player_0_profile_name = "SteamDeck";
    }
  ));
in {
  environment.systemPackages = [eden];
  jovian.decky-loader.extraPackages = [eden];
  jovian.devices.steamdeck.enableGyroDsuService = true;

  # Mutable seed-only copies retain existing configuration and subsequent GUI edits.
  systemd.tmpfiles.rules = [
    "d ${configDir} 0755 ${user} ${group} -"
    "d ${configDir}/input 0755 ${user} ${group} -"
    "C ${configDir}/qt-config.ini 0644 ${user} ${group} - ${globalSeed}"
    "C ${configDir}/input/SteamDeck.ini 0644 ${user} ${group} - ${profileSeed}"
  ];
}
