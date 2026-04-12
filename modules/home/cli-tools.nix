# CLI tools module for Home Manager
{ config, pkgs, lib, ... }:

{
  options.modules.cli-tools.enable = lib.mkEnableOption "CLI tools";

  config = lib.mkIf config.modules.cli-tools.enable {
    home.packages = with pkgs; [
      pass
      podman-tui
    ];
  };
}
