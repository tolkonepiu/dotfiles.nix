{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.noctalia.settings = {
    shell = {
      session = {
        grid = true;
        grid_columns = 2;
        show_shortcuts = false;
        actions = [
          {
            action = "logout";
            label = "Return to Gaming Mode";
            glyph = "device-gamepad";
            # End the native desktop session; Jovian resumes Gaming Mode.
            command = "niri msg action quit --skip-confirmation";
          }
          {
            action = "suspend";
            label = "Sleep";
          }
          {
            action = "reboot";
            label = "Restart";
            countdown_seconds = 5.0;
          }
          {
            action = "shutdown";
            label = "Shut Down";
            countdown_seconds = 5.0;
          }
        ];
      };
    };
    # No automatic screen locking
    lockscreen = {
      enabled = false;
      lock_before_suspend = false;
    };
    # Use a local encryption key instead of GNOME Keyring
    storage = {
      key_source = "file";
      key_file = "${config.home.homeDirectory}/.local/share/noctalia/storage.key";
    };
  };

  # Generate a persistent encryption key on first activation.
  home.activation.noctaliaStorageKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
    key="${config.home.homeDirectory}/.local/share/noctalia/storage.key"

    if [ ! -f "$key" ]; then
      # Restrict access to the key directory.
      ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$key")"
      ${pkgs.coreutils}/bin/chmod 700 "$(${pkgs.coreutils}/bin/dirname "$key")"

      # Generate the key with owner-only permissions.
      umask 077
      ${pkgs.openssl}/bin/openssl rand -hex 32 > "$key"
    fi
  '';
}
