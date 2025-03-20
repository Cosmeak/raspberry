{ config, pkgs, lib, ... }:
let
  cfg = config.mgt.suites.development;
in
{
  options.mgt.suites.development = {
    enable = lib.mkEnableOption "development suite for magnetis";
  };

  config = lib.mkIf cfg.enable ({
    environment.systemPackages = with pkgs; [
      php84
      nodejs_23
    ];
  });
}