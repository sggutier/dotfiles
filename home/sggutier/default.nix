# Home Manager configuration for sggutier
# This file contains shared configuration and imports all modules.
# Host-specific modules are enabled in enkidu.nix or wall-e.nix.
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    # Shell configuration (always enabled)
    ../../modules/home/shell.nix

    # Optional modules (enabled per-host)
    ../../modules/home/cli-tools.nix
    ../../modules/home/terminals.nix
    ../../modules/home/desktop/kde.nix
    ../../modules/home/desktop/apps.nix
    ../../modules/home/media.nix
    ../../modules/home/emacs.nix
  ];

  home.username = "sggutier";
  home.homeDirectory = "/home/sggutier";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Git configuration
  programs.git = {
    enable = true;
    settings.user.name = "Saul Gutierrez";
    # settings.user.email = "your@email.com";  # Uncomment and set
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with.
  home.stateVersion = "24.11";
}
