{
  boot = {
    plymouth.enable = true;
    consoleLogLevel = 3;
    kernelParams = ["quiet" "udev.log_level=3" "systemd.show_status=auto"];
    initrd.availableKernelModules = ["nvme"];
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        # Landscape orientation for Steam Deck.
        consoleMode = "5";
      };
      efi.canTouchEfiVariables = true;
      grub.enable = false;
    };
  };
}
