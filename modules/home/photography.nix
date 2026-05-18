# Photography tools module for Home Manager
{ config, pkgs, lib, ... }:

{
  options.modules.photography.enable = lib.mkEnableOption "Photography tools";

  config = lib.mkIf config.modules.photography.enable {
    home.packages = with pkgs; [
      darktable      # RAW photo development and workflow
      hugin          # Panorama stitching
      exiftool       # CLI metadata inspection and editing
    ];
  };
}
