# Terminal emulators module for Home Manager
{ config, pkgs, lib, ... }:

{
  options.modules.terminals.enable = lib.mkEnableOption "Terminal emulators";

  config = lib.mkIf config.modules.terminals.enable {
    home.packages = with pkgs; [
      kitty
      unstable.wezterm
      unstable.ghostty
    ];
  };
}
