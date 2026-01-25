# Media tools module for Home Manager
{ config, pkgs, lib, ... }:

{
  options.modules.media.enable = lib.mkEnableOption "Media tools";

  config = lib.mkIf config.modules.media.enable {
    home.packages = with pkgs; [
      nomacs
      mpv
      webcamoid
      freetype
      fontconfig
      ffmpeg
      texlive.combined.scheme-full
      pandoc
      xsane
    ];
  };
}
