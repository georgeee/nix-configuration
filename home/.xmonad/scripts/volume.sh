#!/usr/bin/env sh

defaultSink=`pactl info | grep 'Default Sink' | sed 's/^.*: //'`

case "$1" in
  inc)
    pactl set-sink-mute "$defaultSink" 0
    pactl set-sink-volume "$defaultSink" +5%
    ;;
  dec)
    pactl set-sink-mute "$defaultSink" 0
    pactl set-sink-volume "$defaultSink" -5%
    ;;
  mute)
    pactl set-sink-mute "$defaultSink" toggle
    ;;
esac
