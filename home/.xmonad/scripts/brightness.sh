#!/usr/bin/env sh

bfile=/sys/class/backlight/intel_backlight/brightness
maxbfile=/sys/class/backlight/intel_backlight/max_brightness

curb=`cat $bfile`
maxb=`cat $maxbfile`

case "$1" in
  inc)
    if [[ $curb -lt $maxb ]]; then
      echo $((curb+1)) > $bfile
    fi
    ;;
  dec)
    if [[ $curb -gt 1 ]]; then
      echo $((curb-1)) > $bfile
    fi
    ;;
esac
