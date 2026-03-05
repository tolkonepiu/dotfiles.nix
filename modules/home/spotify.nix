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
      if ! /usr/bin/stat -f "%Sf" "$autoUpdatePath" 2> /dev/null | grep -q uchg; then
        rm -rf "$autoUpdatePath"
        mkdir -p "$autoUpdatePath"
        /usr/bin/chflags uchg "$autoUpdatePath"
      fi
    ''
  );

  programs.spicetify = {
    enable = true;
    spotifyPackage = pkgs.spotify;

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
