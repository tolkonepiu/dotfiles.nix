{
  lib,
  pkgs,
  flake,
  config,
  ...
}: let
  inherit (flake) inputs;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in {
  imports = [inputs.spicetify-nix.homeManagerModules.default];

  # Create a home manager activation script to prevent spotify from asking to update
  home.activation.removeSpotifyDarwinAutoUpdate = lib.mkIf isDarwin (
    lib.hm.dag.entryAfter ["writeBoundary"] ''
      autoUpdatePath="${config.home.homeDirectory}/Library/Application Support/Spotify/PersistentCache/Update"
      if [ -d "$autoUpdatePath" ] && [ "$(ls -A "$autoUpdatePath")" ]; then
        rm -rf "$autoUpdatePath"
      fi
    ''
  );

  programs.spicetify = {
    enable = true;

    theme = spicePkgs.themes.catppuccin;
    colorScheme = "mocha";

    enabledExtensions = with spicePkgs.extensions; [
      adblock
      shuffle
      copyLyrics
      hidePodcasts
      volumePercentage
    ];
  };
}
