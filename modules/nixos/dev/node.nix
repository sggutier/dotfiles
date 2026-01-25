# Node.js development module
{ config, options, lib, pkgs, ... }:

with lib;
let
  devCfg = config.modules.dev;
  cfg = devCfg.node;
in
{
  options.modules.dev.node = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Node.js development";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nodejs
      yarn
    ];
  };
}
