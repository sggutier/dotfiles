# Go development module
{ config, options, lib, pkgs, ... }:

with lib;
let
  devCfg = config.modules.dev;
  cfg = devCfg.go;
in
{
  options.modules.dev.go = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Go development";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      unstable.go
      unstable.gopls
      unstable.delve
      unstable.gotools
    ];
  };
}
