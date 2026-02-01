# Hardware configuration for wall-e (NAS)
# Generated from nixos-generate-config on the target machine
#
# ZFS Pool Setup (one-time, after first boot):
#
# 1. Identify drives:
#    lsblk -o NAME,SIZE,MODEL,SERIAL
#    ls -la /dev/disk/by-id/
#
# 2. Create mirror pool with 4TB drives (use legacy mountpoint for NixOS control):
#    sudo zpool create -o ashift=12 \
#      -O acltype=posixacl \
#      -O xattr=sa \
#      -O compression=lz4 \
#      -O atime=off \
#      -O mountpoint=none \
#      tank mirror /dev/disk/by-id/DISK1 /dev/disk/by-id/DISK2
#
# 3. Add L2ARC cache with 1TB drive:
#    sudo zpool add tank cache /dev/disk/by-id/CACHE_DISK
#
# 4. Create dataset with legacy mountpoint (NixOS manages the actual mount):
#    sudo zfs create -o mountpoint=legacy tank/share
#
# 5. Set up Samba password for your user:
#    sudo smbpasswd -a sggutier
#
# Note: Mounting and permissions are handled declaratively by NixOS via
# fileSystems and systemd.tmpfiles.rules in the nas module.
#
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/18e29c94-ae87-4209-bd58-2f23b3ff9e0a";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/499A-0BA1";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/2665aec3-1d0f-40a5-a5a1-f2e9d7186cb8"; }
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
