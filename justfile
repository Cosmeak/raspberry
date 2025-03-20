default:
  @just --list

clean:
  nix-store --optimize
  nix-collect-garbage -d
  sudo nix-collect-garbage -d

nix-size:
  du -sh /nix/store

build-config target:
    sudo nixos-rebuild switch --flake .#rpi3 --target-host {{target}}

build-image:
    sudo nix build .#packages.aarch64-linux.sdcard
