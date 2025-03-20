default:
  @just --list

clean:
  nix-store --optimize
  nix-collect-garbage -d
  sudo nix-collect-garbage -d

nix-size:
  du -sh /nix/store