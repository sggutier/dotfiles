# NixOS configuration for wall-e (minimal server)
{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/nas.nix
    ../../modules/nixos/dev/rust.nix
    ../../modules/nixos/dev/node.nix
    ../../modules/nixos/dev/python.nix
    ../../modules/nixos/dev/java.nix
    ../../modules/nixos/dev/tools.nix
  ];

  # Boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "wall-e";
  networking.networkmanager.enable = true;

  # Time and locale
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Keyboard layout (Dvorak Programmer)
  services.xserver.xkb = {
    layout = "us";
    variant = "dvp";
  };

  # Enable common system packages
  modules.common.enable = true;
  # No dev tools or virtualization on server
  modules.common.devTools.enable = false;
  modules.common.virtualization.enable = false;

  # NAS configuration
  modules.nas = {
    enable = true;
    poolName = "tank";
    encrypted = true;
    datasets.share = {
      mountpoint = "/tank/share";
      share = true;
    };
    samba.enable = true;
    nfs = {
      enable = true;
      allowedNetworks = [ "192.168.0.0/24" ];
    };
  };

  # Shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # GPG agent with SSH support
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # SSH configuration - enabled with password and key auth
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
      PubkeyAuthentication = true;
      AcceptEnv = "COLORTERM";
    };
  };

  # User account
  users.users.sggutier = {
    isNormalUser = true;
    description = "Saul Gutierrez";
    extraGroups = [ "wheel" "networkmanager" "nas" ];
    openssh.authorizedKeys.keys = [
      # Add your SSH public keys here
      # "ssh-ed25519 AAAA... user@host"
    ];
  };

  # Immich photo management
  # Post-deploy: create media dir manually if it doesn't exist:
  #   sudo mkdir -p /tank/immich && sudo chown immich:immich /tank/immich
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = 2283;
    mediaLocation = "/tank/immich";
    openFirewall = true;
    accelerationDevices = null;
  };

  # VA-API hardware acceleration for Immich video transcoding
  hardware.graphics.enable = true;
  users.users.immich.extraGroups = [ "video" "render" ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11";
}
