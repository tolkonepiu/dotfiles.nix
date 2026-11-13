# Install NixOS on Steam Deck

This installs this repository's `chch-deck` configuration from a live NixOS
USB image, with the installation commands run over SSH from another computer.

> [!WARNING]
> Disko **erases the entire internal disk**, including SteamOS, games, and
> recovery partitions. Back up anything you need first. The configuration
> targets `/dev/nvme0n1`; do not use it unchanged on an eMMC Deck or if your
> intended disk has a different device name.

## 1. Prepare and boot the installer

1. Download a current **64-bit Intel/AMD (`x86_64`) graphical NixOS ISO**
   from [NixOS Downloads](https://nixos.org/download/), and write it as a disk
   image to a USB drive. Copying the ISO file onto the drive is not enough.
2. Connect the Deck to power. A USB-C dock with a keyboard and Ethernet makes
   installation easier; Wi-Fi also works. Disconnect other storage devices
   and remove the microSD card to avoid selecting the wrong disk.
3. Fully shut down the Deck, then connect the installer USB drive.
4. Hold **Volume Up** and press **Power**. Release Volume Up when the chime
   sounds. Select **Boot Manager** using the D-pad and **A**, then choose
   **EFI USB Device**. Alternatively, **Volume Down + Power** opens the boot
   menu directly.
5. Boot the NixOS live environment. Use its terminal, not the graphical
   installation wizard: disk layout and installation are handled below.

The button sequences are documented in Valve's
[SteamOS repair instructions](https://help.steampowered.com/en/faqs/view/65B4-2AA3-5F37-4227)
and [Windows resources](https://help.steampowered.com/en/faqs/view/6121-ECCD-D643-BAA8).

## 2. Enable remote access in the live environment

Connect to the network using the desktop network menu, or run `nmtui`.
In the Deck's terminal, as the live environment's `nixos` user:

```sh
passwd
ip -br address
systemctl is-active sshd
```

Set a temporary password for `nixos` and note the Deck's LAN IP address.
The official installer already runs SSH: **setting a password makes password
login possible; it does not start the SSH server**. If the service is not
active, run `sudo systemctl start sshd` and check again. Use a trusted network
while temporary password access is enabled.

On your other computer, replace the example address with the Deck's address:

```sh
ssh nixos@192.168.1.50
```

## 3. Fetch the configuration and accept its binary caches

Run everything below **in the SSH session on the Deck**, not on your other
computer. Enter a root shell; the live installer allows passwordless sudo:

```sh
sudo -i
export NIX_CONFIG='experimental-features = nix-command flakes
accept-flake-config = true'

git clone https://github.com/tolkonepiu/dotfiles.nix.git /root/dotfiles.nix
cd /root/dotfiles.nix
```

Keep this root shell open for the remaining steps. The exported settings
enable flakes in the installer and accept this repository's `nixConfig`.
The build and installation commands also explicitly accept flake settings.
This loads the cache URLs **and signing keys** from `flake.nix`; there is no
need to copy a separate cache list or disable signature verification.
Caches reduce compilation only when the requested build is available there.

Before installing, review these repository-specific settings:

- [`disko.nix`](../configurations/nixos/chch-deck/disko.nix): the target disk
  is `/dev/nvme0n1`, with a 2 GiB EFI partition and Btrfs subvolumes for
  `/`, `/home`, `/nix`, `/var/log`, and `/games`. There is no disk encryption.
- [`chch.nix`](../configurations/home/chch.nix): the installed user is
  `chch`, and SSH trusts the public keys in `me.authorizedKeys`. Make sure
  you have the matching private key before relying on remote access.
- Automatic updates follow this repository's `main` branch. If adapting
  the configuration, keep your changes in a fork and change
  `system.autoUpgrade.flake` accordingly; local installation edits alone
  will not survive an update from upstream.

## 4. Partition, format, and mount with Disko

First inspect the actual disks and confirm the NVMe model and size:

```sh
lsblk -o NAME,PATH,SIZE,MODEL,TRAN,MOUNTPOINTS
lsblk /dev/nvme0n1
```

**Stop if `/dev/nvme0n1` is not the disk you intend to erase.** Do not
substitute a USB drive or microSD card. The next build uses the Disko version
and complete host configuration pinned by this repository's `flake.lock`:

```sh
nix build --accept-flake-config --no-write-lock-file \
  .#nixosConfigurations.chch-deck.config.system.build.diskoScript \
  --out-link /tmp/deck-disko
```

**The next command destroys the existing disk contents**, creates the new
filesystems, and mounts them under `/mnt`:

```sh
/tmp/deck-disko
findmnt -R /mnt
```

Check that `/mnt`, `/mnt/boot`, and the Btrfs subvolume mounts are present.
Do not generate a new hardware configuration or partition the disk again:
the host already declares its boot settings and Disko layout.

## 5. Install and set the installed user's password

Still in the same root shell and repository directory:

```sh
nixos-install --option accept-flake-config true --flake .#chch-deck
```

Wait for installation to finish successfully. If prompted, set the installed
root account's password for local recovery. Then set a password for the
normal user; the live environment's temporary password is not carried over:

```sh
nixos-enter --root /mnt -c 'passwd chch'
```

The `chch` password is needed for local login and sudo. The installed system
allows SSH **only as a normal user with an authorized key**: password SSH
and root SSH login are disabled. This differs from the live installer.

If installation fails, fix the reported error and retry `nixos-install`.
**Do not rerun Disko** unless you deliberately want to erase the disk again.

## 6. Reboot into the installed system

```sh
reboot
```

Remove the installer USB drive during the reboot. The Deck should start
Steam Gaming Mode; Desktop Mode uses niri and Noctalia. Reconnect to the
network if needed: the live environment's Wi-Fi settings may not carry over.

For SSH after installation, use `ssh chch@DECK_IP` with your authorized key
and the Deck's current address, not the installer's `nixos` account.

## References

- [NixOS manual: installation](https://nixos.org/manual/nixos/stable/#sec-installation-manual)
- [Disko quickstart](https://github.com/nix-community/disko/blob/master/docs/quickstart.md)
