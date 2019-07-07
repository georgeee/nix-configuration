#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd "$DIR"

mkdir -p home/.xmonad home/.local/share home/.kde/share/apps home/.config

  rsync -r /etc/nixos/* global && \
  rsync -r ~/.xmonad/{xmonad.hs,scripts} home/.xmonad && \
  cp ~/{.gitconfig,.bg.jpg,.emacs,.tmux.conf} home && \
  rsync -r ~/.local/share/konsole home/.local/share && \
  rsync -r ~/.kde/share/apps/konsole home/.kde/share/apps && \
  rsync -r ~/.config/taffybar home/.config && \
  git add home global && \
  git commit -m "Updated configuration" ; git push
