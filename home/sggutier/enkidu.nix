# Host-specific Home Manager configuration for enkidu (full desktop)
{ config, pkgs, lib, ... }:

{
  # Enable modules for full desktop experience
  modules.cli-tools.enable = true;
  modules.terminals.enable = true;
  modules.desktop.kde.enable = true;
  modules.desktop.apps.enable = true;
  modules.media.enable = true;
  modules.emacs.enable = true;
}
