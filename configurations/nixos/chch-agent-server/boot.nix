{
  hardware.cpu.amd.updateMicrocode = true;
  # RAID0 cannot rebuild, and no monitoring alert destination is configured.
  systemd.services.mdmonitor.enable = false;
  boot = {
    initrd.availableKernelModules = ["nvme" "raid0"];
    supportedFilesystems = ["btrfs"];
    swraid.enable = true;
    loader = {
      efi.canTouchEfiVariables = false;
      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        # Independent ESPs each get EFI/BOOT/BOOTX64.EFI, without NVRAM entries.
        mirroredBoots = [
          {
            path = "/boot";
            devices = ["nodev"];
          }
          {
            path = "/boot-fallback";
            devices = ["nodev"];
          }
        ];
      };
    };
  };
}
