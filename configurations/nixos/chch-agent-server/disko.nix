{flake, ...}: let
  btrfsOptions = ["compress=zstd:3" "noatime"];
in {
  imports = [flake.inputs.disko.nixosModules.disko];

  disko.devices = {
    disk = {
      primary = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            raid = {
              size = "100%";
              type = "FD00";
              content = {
                type = "mdraid";
                name = "root";
              };
            };
          };
        };
      };
      secondary = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot-fallback";
                mountOptions = ["umask=0077"];
              };
            };
            raid = {
              size = "100%";
              type = "FD00";
              content = {
                type = "mdraid";
                name = "root";
              };
            };
          };
        };
      };
    };
    # RAID0 has NO redundancy: losing either NVMe loses the entire filesystem.
    mdadm.root = {
      type = "mdadm";
      level = 0;
      metadata = "1.2";
      content = {
        type = "btrfs";
        subvolumes = {
          "/@root" = {
            mountpoint = "/";
            mountOptions = btrfsOptions;
          };
          "/@nix" = {
            mountpoint = "/nix";
            mountOptions = btrfsOptions;
          };
          "/@home" = {
            mountpoint = "/home";
            mountOptions = btrfsOptions;
          };
          "/@log" = {
            mountpoint = "/var/log";
            mountOptions = btrfsOptions;
          };
          "/@docker" = {
            mountpoint = "/var/lib/docker";
            mountOptions = btrfsOptions;
          };
        };
      };
    };
  };
}
