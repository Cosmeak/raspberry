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

        # Configuration
        ({ self, inputs, pkgs, lib, ... }: { config = { 
          # Used to build image/version
          nixpkgs.buildPlatform.system = "x86_64-linux";
          nixpkgs.hostPlatform.system = "aarch64-linux";
          nixpkgs.config.allowUnsupportedSystem = true;

          # Networking configuration
          networking.hostName = "rpi";
          networking.interfaces."wlan0".useDHCP = true;
          networking.wireless = {
            enable = true;
            interfaces = [ "wlan0" ];
          };

          # Window Manager (see https://wiki.nixos.org/wiki/Dwm & https://dwm.suckless.org/)
          services.xserver.windowManager.dwm.enable = true;

          # System wide packages (see https://search.nixos.org/packages)
          environment.systemPackages  = with pkgs; [
            firefox
          ];

          # Users configuration
          users.users."rpi" = {
            isNormalUser = true;
            # wheel = admin
            extraGroups = [ "wheel" ]; 
            # password generated with `mkpasswd` command
            hashedPassword = "$y$j9T$rg0syrPPtjaLILPTTplI3/$5uykqP9tXjAsvOocbfosUeN6j6dMrHRUtwudKd4QaA5"; 

            # User wide packages
            packages = [];
          };

          # Perform garbage collection weekly to maintain low disk usage
          nix.gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 1w";
          };

          # Optimize storage
          # You can also manually optimize the store via:
          #    nix-store --optimise
          # Refer to the following link for more details:
          # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
          nix.settings.auto-optimise-store = true;

          # TODO: auto update flake.lock with reboot

          # TODO: wake-on-lan at 9:00 + auto shutdown at 18:00
          # wake up TV with it and shut it down too

          # This value determines the NixOS release from which the default
          # settings for stateful data, like file locations and database versions
          # on your system were taken. It‘s perfectly fine and recommended to leave
          # this value at the release version of the first install of this system.
          # Before changing this value read the documentation for this option
          # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
          system.stateVersion = "24.11";
        };})
      ];
    };
  };
}