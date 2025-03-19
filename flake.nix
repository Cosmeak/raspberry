{
  description = "NixOS Raspberry Pi configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, hardware, ... }@inputs: {
    # Raspberry configuration
    nixosConfigurations.rpi3 = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        # SD card image fro aarch64 architecture
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        # Raspberry Pi 3 hardware modules
        hardware.nixosModules.raspberry-pi-3
        # Configuration module for the raspberry
        ./config/rpi3.nix
      ];
    };
  };
}
