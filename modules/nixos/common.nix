# Common NixOS system configuration module
{ config, pkgs, lib, ... }:

{
  options.modules.common = {
    enable = lib.mkEnableOption "Common system packages";

    devTools.enable = lib.mkEnableOption "Development tools (gcc, cmake, gnumake)";

    virtualization.enable = lib.mkEnableOption "Virtualization tools (libvirt, virt-manager)";
  };

  config = lib.mkIf config.modules.common.enable {
    environment.systemPackages = with pkgs;
      [
        vim
        wget
        git
        htop
        btop
        curl
        zip
        unzip
        unrar
        python3
        sapling
        tree
        cacert
        ripgrep
        fd
        fastfetch
        usbutils
        pciutils
        nix-index
        screen
      ]
      ++ lib.optionals config.modules.common.devTools.enable [
        cmake
        gcc
        gnumake
      ]
      ++ lib.optionals config.modules.common.virtualization.enable [
        libvirt
        virt-manager
      ];
  };
}
