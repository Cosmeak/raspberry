{ config, pkgs, inputs, ... }:
{
  imports = [
    # SD card image fro aarch64 architecture
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    # Raspberry Pi 3 hardware modules
    inputs.hardware.nixosModules.raspberry-pi-3
  ];

  # Used to build image/version
  nixpkgs.buildPlatform.system = "x86_64-linux";
  nixpkgs.hostPlatform.system = "aarch64-linux";

  # Allow licensed firmware to be update
  hardware.enableRedistributableFirmware = true;

  # Early boot
  boot.initrd.kernelModules = [ "vc4" "bcm2835_dma" "i2c_bcm2835" ];

  # Network 
  networking.hostName = "rpi3";
  networking.wireless.enable = true;
  networking.wireless.interfaces = [ "wlan0" ];
  networking.interfaces."wlan0".useDHCP = true;

  # Time
  time.timeZone = "Europe/Paris";

  # Keyboard
  services.xserver.xkb.layout = "fr,us";
  services.xserver.xkb.options = "grp:win_space_toggle";

  # Desktop
  services.xserver.enable = true;
  services.xserver.desktopManager.lxqt.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.displayManager.defaultSession = "lxqt";

  # Environment wide packages
  environment.systemPackages = with pkgs; [
    libraspberrypi
    git
    vim
    nano
    firefox
    foot
    udisks
  ];

  # TODO: auto update flake.lock with reboot (build from action ?)

  # TODO: wake up at 9:00 + auto shutdown at 18:00
  # TODO: wake-on-lan TV

  # Configure users
  users.mutableUsers = true;
  users.users.magnetis = {
    description = "magnetis";
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ]; # wheel = admin
    # password generated with `mkpasswd` command
    # hashedPassword = "$y$j9T$rg0syrPPtjaLILPTTplI3/$5uykqP9tXjAsvOocbfosUeN6j6dMrHRUtwudKd4QaA5";
  };

  # Nix settings
  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.trusted-users = [ "root" "@wheel" ];

  # Garbage collection
  mgt.system.garbageCollector.enable = true;
}
