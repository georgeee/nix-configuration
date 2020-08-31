#!/usr/bin/env sh

p='haskellPackages.ghcWithPackages (pkgs: with pkgs; [xmonad xmonad-contrib taffybar])'

nix-shell -I/home/georgeee/.nix-defexpr/channels/1809/nixpkgs -p "$p" --run "xmonad --recompile"
nix-shell -I/home/georgeee/.nix-defexpr/channels/1809/nixpkgs -p "$p" --run taffybar
