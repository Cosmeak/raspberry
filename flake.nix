{
  description = "NixOS Raspberry Pi configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, hardware, ... }@inputs: 
  let
    forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
  in {
    # Raspberry configuration
    nixosConfigurations.rpi3 = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit inputs; };
      modules = [ ./config/rpi3.nix ./modules/nixos/system/garbage-collector ];
    };

    # Windows Subsystem for Linux (WSL)
    # nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
    #   system = "x86_64-linux";
    #   specialArgs = { inherit inputs; };
    #   modules = [ ./config/wsl.nix ];
    # };

    # Macos
    # darwinConfigurations.macos = nixpkgs.lib.nixosSystem {
    #   system = "aarch64-darwin";
    #   specialArgs = { inherit inputs; };
    #   modules = [ ./config/macos.nix ];
    # };

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
