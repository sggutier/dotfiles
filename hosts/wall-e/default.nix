# NixOS configuration for wall-e (minimal server)
{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/dev/rust.nix
    ../../modules/nixos/dev/node.nix
    ../../modules/nixos/dev/python.nix
    ../../modules/nixos/dev/java.nix
    ../../modules/nixos/dev/tools.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "wall-e";
  networking.networkmanager.enable = true;

  # Time and locale
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable common system packages
  modules.common.enable = true;
  # No dev tools or virtualization on server
  modules.common.devTools.enable = false;
  modules.common.virtualization.enable = false;

  # Shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # SSH configuration - enabled with password and key auth
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
      PubkeyAuthentication = true;
    };
  };

  # User account
  users.users.sggutier = {
    isNormalUser = true;
    description = "Saul Gutierrez";
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      # Add your SSH public keys here
      # "ssh-ed25519 AAAA... user@host"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";
}
