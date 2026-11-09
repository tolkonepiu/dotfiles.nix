{flake, ...}: let
  btrfsOptions = [
    "compress=zstd:3"
    "noatime"
  ];
in {
  imports = [flake.inputs.disko.nixosModules.disko];

  disko.devices.disk.internal = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "2G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = ["umask=0077"];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            subvolumes = {
              "/@root" = {
                mountpoint = "/";
                mountOptions = btrfsOptions;
              };
              "/@home" = {
                mountpoint = "/home";
                mountOptions = btrfsOptions;
              };
              "/@nix" = {
                mountpoint = "/nix";
                mountOptions = btrfsOptions;
              };
              "/@log" = {
                mountpoint = "/var/log";
                mountOptions = btrfsOptions;
              };
              "/@games" = {
                mountpoint = "/games";
                mountOptions = btrfsOptions;
              };
            };
          };
        };
      };
    };
  };
}
