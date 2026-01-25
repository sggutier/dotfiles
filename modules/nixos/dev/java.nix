# Java development module
{ config, options, lib, pkgs, ... }:

with lib;
let
  devCfg = config.modules.dev;
  cfg = devCfg.java;
in
{
  options.modules.dev.java = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Java development";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      jdk
      maven
    ];
  };
}
