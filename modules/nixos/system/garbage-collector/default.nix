{ config, pkgs, lib, ... }:
let
  cfg = config.mgt.system.garbageCollector;
in
{
  options.mgt.system.garbageCollector = {
    enable = lib.mkEnableOption "garbage collection.";
  };

  config = lib.mkIf cfg.enable ({
    # Perform garbage collection weekly to maintain low disk usage
    nix.gc.automatic = true;
    nix.gc.dates = "weekly";
    nix.gc.options = "--delete-older-than 1w";

    # Optimize storage
    nix.settings.auto-optimise-store = true;
  });
}