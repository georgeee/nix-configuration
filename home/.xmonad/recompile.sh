#!/usr/bin/env sh

p='haskellPackages.ghcWithPackages (pkgs: with pkgs; [xmonad xmonad-contrib taffybar])'

nix-shell -p "$p" --run "xmonad --recompile"
nix-shell -p "$p" --run taffybar
