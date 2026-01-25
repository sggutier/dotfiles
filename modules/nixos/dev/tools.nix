# Development tools module
{ config, options, lib, pkgs, ... }:

with lib;
let
  devCfg = config.modules.dev;
  cfg = devCfg.tools;
in
{
  options.modules.dev.tools = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable development tools";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gh
      cmake
      clang
      clang-tools
      gdb
      sqlite
    ];
  };
}
