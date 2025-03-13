{
    description = "Magnetis Rasberry Pi services";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
        hardware.url = "github:NixOS/nixos-hardware/master";
    };

    outputs = { self, nixpkgs, hardware, ... }@inputs: 
    {
        # Raspberry Pi 4 configuration
        nixosConfiguration."rpi" = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";

            modules = [ 
                hardware.nixosModules.rapsberry-pi-4 
                "${nixpkgs}/nixos/modules/profiles/minimal.nix"
                {
                    # Force update to the last linux kernel avalaible
                    boot.kernelPackages = nixpkgs.linuxPackages_latest;

                    # Special hardware config for raspberry
                    hardware = {
                        raspberry-pi."4".apply-overlays-dtmerge.enable = true;
                        raspberry-pi."4".fkms-3d.enable = true; # Enable hardware acceleration
                        deviceTree = {
                            enable = true;
                            filter = "*rpi-4-*.dtb";
                        };
                    };

                    # Networking configuration
                    networking = {
                        hostname = "rpi";
                        interfaces."wlan0".useDHCP = true;
                        wireless = {
                            enable = true;
                            interface = [ "wlan0" ];
                        };
                    };

                    users.users."rpi" = {
                        isNormalUser = true;
                        extraGroups = [ "wheel" ];
                        hashedPassword = "$y$j9T$rg0syrPPtjaLILPTTplI3/$5uykqP9tXjAsvOocbfosUeN6j6dMrHRUtwudKd4QaA5"; # password generated with `mkpasswd` command

                        # User wide packages
                        packages = [];
                    };

                    # System wide packages
                    environment.systemPackages = with nixpkgs; [
                        libraspberrypi
                        raspberrypi-eeprom
                    ];

                    # Garbage collector
                    nix.gc = {
                        automatic = true;
                        dates = "weekly";
                        options = "--delete-older-than 7d";
                    };

                    nix.settings = {
                        auto-optimise-store = true; # Related to garbage collector
                        experimental-features = "nix-command flakes"; # Enable flakes
                    };

                    # "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" creates a
                    # disk with this label on first boot. Therefore, we need to keep it. It is the
                    # only information from the installer image that we need to keep persistent
                    fileSystems."/" = {
                        device = "/dev/disk/by-label/NIXOS_SD";
                        fsType = "ext4";
                    };  

                    # This value determines the NixOS release from which the default
                    # settings for stateful data, like file locations and database versions
                    # on your system were taken. It‘s perfectly fine and recommended to leave
                    # this value at the release version of the first install of this system.
                    # Before changing this value read the documentation for this option
                    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
                    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
                    system.stateVersion = "24.11"; # Did you read the comment?
                }
            ];
            
        };

        # SD Card image builder
        images."rpi" = (self.nixosConfiguration."rpi".extendModules {
            modules = [ 
                "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
                {
                    # We don't need this defaults modules
                    disableModules = ["profiles/base.nix"];

                    # Copy configuration files to system
                    environment.etc."nixos".source = ./.;

                    # Patch build images on x86-64 systems
                    nixpkgs.config.allowUnsupportedSystem = true;
                    nixpkgs.hostPlatform.system = "armv7l-linux";
                    nixpkgs.buildPlatform.system = "x86_64-linux";   
                }
            ];
        }).config.system.build.sdImage;
    };
}