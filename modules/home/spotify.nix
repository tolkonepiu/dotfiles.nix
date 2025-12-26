{
  lib,
  pkgs,
  flake,
  config,
  ...
}: let
  inherit (flake) inputs;
  inherit (pkgs.stdenv.hostPlatform) isDarwin isAarch64;
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};

  # FIXME: Temporary fix until nixpkgs provides a working Spotify package for Darwin ARM64
  # archive.org doesn't provide a stable URL and it's currently broken
  # https://github.com/NixOS/nixpkgs/issues/465676
  spotifyPackage =
    if (isDarwin && isAarch64)
    then
      pkgs.spotify.overrideAttrs {
        version = "1.2.79.427";
        src = pkgs.fetchurl {
          url = "https://web.archive.org/web/20251225143128/https://download.scdn.co/SpotifyARM64.dmg";
          hash = "sha256-jOn4hPbxIQncdjkuySTsBaFzM6VpojbMMgph/Vpah1k=";
        };
      }
    else pkgs.spotify;
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
    inherit spotifyPackage;

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
