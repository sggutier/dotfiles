# Home Manager configuration for sggutier
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../modules/home/shell.nix
  ];

  home.username = "sggutier";
  home.homeDirectory = "/home/sggutier";

  # User packages (migrated from configuration.nix)
  home.packages = with pkgs; [
    # Terminal & Shell
    podman-tui
    btop
    batmon
    fastfetch
    kitty
    unstable.wezterm
    unstable.ghostty

    # Development
    pyright
    nodejs
    yarn
    poetry
    gh
    sapling
    ripgrep
    fd
    cmake
    clang
    clang-tools
    gdb
    jdk
    maven
    unstable.cargo
    unstable.rustc
    unstable.rust-analyzer
    sqlite

    # Emacs
    ((emacsPackagesFor emacs).emacsWithPackages (epkgs: [
      epkgs.vterm
    ]))

    # Desktop apps
    google-chrome
    discord
    zoom-us
    unstable.spotify
    qbittorrent
    nomacs
    mpv
    webcamoid
    libreoffice-qt6-fresh

    # KDE
    kdePackages.plasma-pa
    kdePackages.ark
    kdePackages.kdegraphics-thumbnailers
    kdePackages.xdg-desktop-portal-kde
    kdePackages.kate
    kara

    # Media & Graphics
    freetype
    fontconfig
    ffmpeg
    texlive.combined.scheme-full
    pandoc
    xsane

    # Utilities
    usbutils
    pciutils
    wine
    unrar
    appimage-run
    pass
    wl-clipboard
    libnotify
    nix-index
    gamescope
    gnome-network-displays
    distrobox
    unstable.claude-code
  ];

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Git configuration (example)
  programs.git = {
    enable = true;
    userName = "Saul Gutierrez";
    # userEmail = "your@email.com";  # Uncomment and set
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with.
  home.stateVersion = "24.11";
}
