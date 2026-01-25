# Emacs module for Home Manager
{ config, pkgs, lib, ... }:

{
  options.modules.emacs.enable = lib.mkEnableOption "Emacs editor";

  config = lib.mkIf config.modules.emacs.enable {
    home.packages = with pkgs; [
      ((emacsPackagesFor emacs).emacsWithPackages (epkgs: [
        epkgs.vterm
      ]))
    ];
  };
}
