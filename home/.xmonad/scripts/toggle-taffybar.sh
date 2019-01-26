#!/usr/bin/env sh

killall -0 taffybar-linux-x86_64

taffyLaunched=$?

if [ $taffyLaunched == 0 ]; then
  killall taffybar-linux-x86_64
else
  taffybar
fi
