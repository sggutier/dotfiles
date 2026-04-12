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
      # GStreamer codecs
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-libav
      gst_all_1.gst-vaapi
    ];
  };
}
