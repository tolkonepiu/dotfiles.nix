{
  config,
  lib,
  pkgs,
  ...
}: let
  paths = import ./paths.nix;
  user = config.jovian.steam.user;
  group = config.users.users.${user}.group;
  configHome = config.home-manager.users.${user}.xdg.configHome;
  configDir = "${configHome}/Cemu";
  dataDir = "${paths.root}/cemu";
  mlcDir = "${dataDir}/mlc01";
  savesDir = "${paths.saves}/cemu";
  romsDir = "${paths.roms}/wiiu";

  # Cemu v2.6 CemuConfig.cpp schema; CemuApp.cpp skips setup when this exists.
  settingsSeed = pkgs.writeText "cemu-settings.xml" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <content>
      <mlc_path>${lib.strings.escapeXML mlcDir}</mlc_path>
      <GamePaths><Entry>${lib.strings.escapeXML romsDir}</Entry></GamePaths>
      <Input><DSUC host="127.0.0.1" port="26760"/></Input>
      <Audio>
        <api>3</api>
        <TVChannels>1</TVChannels>
        <TVVolume>50</TVVolume>
        <TVDevice>default</TVDevice>
      </Audio>
    </content>
  '';

  # Targets Gaming Mode's Steam Input gamepad layout (EmuDeck's standard GUID).
  # Other controller GUIDs must be selected in Cemu's Input settings.
  controllerSeed = pkgs.writeText "cemu-SteamDeck.xml" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <emulated_controller>
      <type>Wii U GamePad</type>
      <profile>SteamDeck</profile>
      <controller>
        <api>DSUController</api>
        <uuid>0</uuid>
        <display_name>Steam Deck Gyroscope</display_name>
        <motion>true</motion>
        <mappings/>
      </controller>
      <controller>
        <api>SDLController</api>
        <uuid>0_030079f6de280000ff11000001000000</uuid>
        <display_name>Steam Virtual Gamepad</display_name>
        <motion>false</motion>
        <rumble>1</rumble>
        <axis><deadzone>0.1</deadzone><range>1</range></axis>
        <rotation><deadzone>0.1</deadzone><range>1</range></rotation>
        <trigger><deadzone>0.1</deadzone><range>1</range></trigger>
        <mappings>
          <!-- Nintendo positional face buttons -->
          <entry><mapping>1</mapping><button>1</button></entry>
          <entry><mapping>2</mapping><button>0</button></entry>
          <entry><mapping>3</mapping><button>3</button></entry>
          <entry><mapping>4</mapping><button>2</button></entry>
          <!-- Shoulders and triggers -->
          <entry><mapping>5</mapping><button>9</button></entry>
          <entry><mapping>6</mapping><button>10</button></entry>
          <entry><mapping>7</mapping><button>42</button></entry>
          <entry><mapping>8</mapping><button>43</button></entry>
          <!-- Plus and minus -->
          <entry><mapping>9</mapping><button>6</button></entry>
          <entry><mapping>10</mapping><button>4</button></entry>
          <!-- D-pad -->
          <entry><mapping>11</mapping><button>11</button></entry>
          <entry><mapping>12</mapping><button>12</button></entry>
          <entry><mapping>13</mapping><button>13</button></entry>
          <entry><mapping>14</mapping><button>14</button></entry>
          <!-- Stick clicks -->
          <entry><mapping>15</mapping><button>7</button></entry>
          <entry><mapping>16</mapping><button>8</button></entry>
          <!-- Left stick: up, down, left, right -->
          <entry><mapping>17</mapping><button>45</button></entry>
          <entry><mapping>18</mapping><button>39</button></entry>
          <entry><mapping>19</mapping><button>44</button></entry>
          <entry><mapping>20</mapping><button>38</button></entry>
          <!-- Right stick: up, down, left, right -->
          <entry><mapping>21</mapping><button>47</button></entry>
          <entry><mapping>22</mapping><button>41</button></entry>
          <entry><mapping>23</mapping><button>46</button></entry>
          <entry><mapping>24</mapping><button>40</button></entry>
        </mappings>
      </controller>
    </emulated_controller>
  '';
in {
  environment.systemPackages = [pkgs.cemu];
  jovian.decky-loader.extraPackages = [pkgs.cemu];
  jovian.devices.steamdeck.enableGyroDsuService = true;

  systemd.tmpfiles.rules =
    map (path: "d ${path} 0755 ${user} ${group} -") [
      dataDir
      mlcDir
      "${mlcDir}/usr"
      savesDir
      romsDir
      configDir
      "${configDir}/controllerProfiles"
    ]
    ++ [
      "d ${configHome} - ${user} ${group} -"
      # Non-forcing link preserves existing MLC saves; no automatic migration.
      "L ${mlcDir}/usr/save - - - - ${savesDir}"
      # Mutable seed-once copies: existing installations require manual adoption.
      "C ${configDir}/settings.xml 0644 ${user} ${group} - ${settingsSeed}"
      "C ${configDir}/controllerProfiles/controller0.xml 0644 ${user} ${group} - ${controllerSeed}"
      "C ${configDir}/controllerProfiles/SteamDeck.xml 0644 ${user} ${group} - ${controllerSeed}"
    ];
}
