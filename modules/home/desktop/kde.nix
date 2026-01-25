# KDE packages module for Home Manager
{ config, pkgs, lib, ... }:

{
  options.modules.desktop.kde.enable = lib.mkEnableOption "KDE packages";

  config = lib.mkIf config.modules.desktop.kde.enable {
    home.packages = with pkgs; [
      kdePackages.plasma-pa
      kdePackages.ark
      kdePackages.kdegraphics-thumbnailers
      kdePackages.xdg-desktop-portal-kde
      kdePackages.kate
      kara
      wl-clipboard
      libnotify
    ];
  };
}
