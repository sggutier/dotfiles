# Emacs module for Home Manager
{ config, pkgs, lib, ... }:

{
  options.modules.emacs.enable = lib.mkEnableOption "Emacs editor";

  config = lib.mkIf config.modules.emacs.enable {
    home.packages = with pkgs; [
      ((emacsPackagesFor emacs).emacsWithPackages (epkgs: [
        epkgs.vterm
      ]))
      # Python deps required by lsp-bridge (https://github.com/manateelazycat/lsp-bridge)
      (python3.withPackages (ps: with ps; [
        epc
        orjson
        sexpdata
        six
        setuptools
        paramiko
        rapidfuzz
        watchdog
        packaging
      ]))
    ];
  };
}
