{
  description = "NixOS Raspberry Pi configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, hardware, ... }@inputs: {
    # Raspberry configuration
    nixosConfigurations.rpi = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        # SD card image
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        # Raspberry Pi 3 hardware modules
        hardware.nixosModules.raspberry-pi-3
        # Configuration module
        ./nixos/rpi.nix
      ];
    };
  };
}
