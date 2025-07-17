{
  lib,
  config,
  ...
}: {
  # create a home manager activation script to prevent spotify from asking to update
  home.activation.removeSpotifyDarwinAutoUpdate = lib.hm.dag.entryAfter ["writeBoundary"] ''
    autoUpdatePath="${config.home.homeDirectory}/Library/Application Support/Spotify/PersistentCache/Update"
    if [ -d "$autoUpdatePath" ] && [ "$(ls -A "$autoUpdatePath")" ]; then
      rm -rf "$autoUpdatePath"
    fi
  '';
}
