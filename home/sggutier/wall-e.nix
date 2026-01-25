# Host-specific Home Manager configuration for wall-e (minimal server)
{ config, pkgs, lib, ... }:

{
  # Enable only essential modules for server
  modules.cli-tools.enable = true;
}
