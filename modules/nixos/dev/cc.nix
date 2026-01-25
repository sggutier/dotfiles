# C/C++ development module
{ config, options, lib, pkgs, ... }:

with lib;
let
  devCfg = config.modules.dev;
  cfg = devCfg.cc;
in
{
  options.modules.dev.cc = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable C/C++ development tools";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      clang
      clang-tools
      gcc
      gdb
      cmake
      gnumake
    ];
  };
}
