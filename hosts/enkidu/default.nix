# NixOS configuration for enkidu
{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "enkidu";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 7236 7250 ];
  networking.firewall.allowedUDPPorts = [ 7236 5353 ];

  # Time and locale
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true;

  # X11 and Desktop
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "dvp";

  # Plasma 6 Desktop Environment
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.displayManager.gdm.settings = { Theme = { CursorTheme = "breeze_cursors"; }; };

  # Programs
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  programs.partition-manager.enable = true;
  programs.kdeconnect.enable = true;
  programs.adb.enable = true;
  programs.dconf.enable = true;
  programs.firefox.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Services
  services.flatpak.enable = true;
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.cnijfilter2 ];

  # Scanning
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.sane-airscan ];
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish.enable = true;
    publish.addresses = true;
    publish.workstation = true;
    openFirewall = true;
  };

  # Fingerprint
  services.fprintd.enable = true;
  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };

  # Audio (PipeWire)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Virtualization
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };

  # Input
  services.libinput.enable = true;

  # User account
  users.users.sggutier = {
    isNormalUser = true;
    description = "Saul Gutierrez";
    extraGroups = [
      "wheel"
      "networkmanager"
      "dialout"
      "adbusers"
      "scanner"
      "lp"
      "libvirtd"
      "video"
      "render"
      "kvm"
      "qemu-libvirtd"
    ];
  };

  # Syncthing
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "sggutier";
    group = "users";
    dataDir = "/home/sggutier/";
    configDir = "/home/sggutier/.config/syncthing";
  };

  # SSH
  services.openssh.enable = true;

  # Suspend-then-hibernate
  systemd.sleep.extraConfig = "HibernateDelaySec=2h";

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    htop
    curl
    cmake
    gcc
    gnumake
    zip
    unzip
    python3
    libvirt
    virt-manager
    cacert
    tree
  ];

  # Enable laptop-specific packages
  modules.laptop.enable = true;

  # Enable development modules
  modules.dev.rust.enable = true;
  modules.dev.node.enable = true;
  modules.dev.python.enable = true;
  modules.dev.java.enable = true;
  modules.dev.tools.enable = true;

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "22.05";
}
