# Hardware configuration for wall-e (NAS)
#
# Disk layout:
#   nvme0n1 (1TB TWSC) - OS drive:
#     p1: 1GB   ESP (FAT32)
#     p2: 16GB  swap (LUKS)
#     p3: 800GB root (LUKS -> ext4)
#     p4: 137GB ZFS L2ARC cache
#
#   nvme1n1 (WD Blue SN5000 4TB)  \
#   nvme2n1 (WD Blue SN5000 4TB)   } ZFS raidz1 "tank" (~7.1TB usable)
#   nvme3n1 (TEAM TM8FFD004T 4TB) /   native encryption (aes-256-gcm)
#
#   mmcblk0 (58GB eMMC) - ZFS SLOG (write cache)
#
# Encryption:
#   LUKS (root + swap): TPM2 auto-unlock + passphrase fallback
#   ZFS (tank): keyfile at /etc/zfs/tank.key (on encrypted root) + passphrase fallback
#
# Post-install setup:
#   1. Enroll TPM2 for LUKS auto-unlock:
#      sudo systemd-cryptenroll --tpm2-device=auto /dev/nvme0n1p3
#      sudo systemd-cryptenroll --tpm2-device=auto /dev/nvme0n1p2
#
#   2. Set up Samba password:
#      sudo smbpasswd -a sggutier
#
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" "tpm_tis" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Use systemd initrd for TPM2 LUKS unlock
  boot.initrd.systemd.enable = true;

  # LUKS encrypted root
  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-partlabel/cryptroot";
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };

  # LUKS encrypted swap
  boot.initrd.luks.devices."cryptswap" = {
    device = "/dev/disk/by-partlabel/cryptswap";
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };

  fileSystems."/" = {
    device = "/dev/mapper/cryptroot";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/efi";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [
    { device = "/dev/mapper/cryptswap"; }
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
