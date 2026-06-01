#!/bin/bash

sock=$(ls "$XDG_RUNTIME_DIR/hypr/"*"/.socket2.sock" 2>/dev/null | head -1)
[ -z "$sock" ] && exit 1

socat -u UNIX-CONNECT:"$sock" - 2>/dev/null | while IFS= read -r line; do
  case "$line" in
    monitoradded\>\>HDMI-A-1*)
      for i in 1 2 3 4 5; do
        hyprctl dispatch moveworkspacetomonitor "$i" HDMI-A-1
      done
      ;;
    monitorremoved\>\>HDMI-A-1*)
      for i in 1 2 3 4 5; do
        hyprctl dispatch moveworkspacetomonitor "$i" eDP-1
      done
      ;;
  esac
done
