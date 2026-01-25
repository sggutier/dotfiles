# Rust development module
{ config, options, lib, pkgs, ... }:

with lib;
let
  devCfg = config.modules.dev;
  cfg = devCfg.rust;
in
{
  options.modules.dev.rust = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Rust development";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      unstable.cargo
      unstable.rustc
      unstable.rust-analyzer
    ];
  };
}
