{ config, pkgs, ... }:
{
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
  ];

  # TODO: auto update flake.lock with reboot (build from action ?)

  # TODO: wake up at 9:00 + auto shutdown at 18:00
  # TODO: wake-on-lan TV

  # Configure users
  users.mutableUsers = false;
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
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 1w";
  nix.settings.auto-optimise-store = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11";
}
