{
  description = "NixOS Raspberry Pi configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    hardware.url = "github:NixOS/nixos-hardware/master";
    generator.url = "github:nix-community/nixos-generators";
    generator.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, hardware, generator, ... }@inputs:
  let
    forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
  in {
    # Raspberry configuration
    nixosConfigurations.rpi3 = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        ./config/rpi3.nix
      ];
    };

    # SD Card image builder
    packages.aarch64-linux.sdcard = generator.nixosGenerate {
      system = "aarch64-linux";
      format = "sd-aarch64";
      specialArgs = { inherit inputs; };
      modules = [
        ./config/rpi3.nix

        # Force some parameters for the image generation
        ({ config, pkgs, lib, ... }:{
          sdImage.compressImage = false;
          fileExtension = lib.mkForce ".img*";
        })
      ];
    };

    # Development shells
    devShells = forAllSystems(system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
        {
          default = pkgs.mkShell ({
            buildInputs = with pkgs; [ just nixd ];
          });
        }
    );
  };
}
