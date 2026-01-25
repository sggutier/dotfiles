# Laptop-specific NixOS system configuration module
{ config, pkgs, lib, ... }:

{
  options.modules.laptop = {
    enable = lib.mkEnableOption "Laptop-specific system packages";
  };

  config = lib.mkIf config.modules.laptop.enable {
    environment.systemPackages = with pkgs; [
      batmon
    ];
  };
}
