# Python development module
{ config, options, lib, pkgs, ... }:

with lib;
let
  devCfg = config.modules.dev;
  cfg = devCfg.python;
in
{
  options.modules.dev.python = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Python development";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pyright
      poetry
    ];
  };
}
