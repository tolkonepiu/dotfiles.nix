{
  boot = {
    # Graphical boot splash.
    plymouth.enable = true;

    # Suppress non-critical kernel messages.
    consoleLogLevel = 3;

    kernelParams = [
      # Reduce kernel boot messages.
      "quiet"
      # Show only udev errors during boot.
      "udev.log_level=3"
      # Show systemd status on significant boot delays.
      "systemd.show_status=auto"
    ];

    loader = {
      systemd-boot = {
        enable = true;
        # Keep the last 10 NixOS generations
        configurationLimit = 10;
      };
      # Disable GRUB in favor of systemd-boot
      grub.enable = false;
    };
  };
}
