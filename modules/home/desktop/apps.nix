# Desktop applications module for Home Manager
{ config, pkgs, lib, ... }:

{
  options.modules.desktop.apps.enable = lib.mkEnableOption "Desktop applications";

  config = lib.mkIf config.modules.desktop.apps.enable {
    home.packages = with pkgs; [
      google-chrome
      discord
      zoom-us
      unstable.spotify
      qbittorrent
      libreoffice-qt6-fresh
      wine
      appimage-run
      gamescope
      gnome-network-displays
      distrobox
    ];
  };
}
