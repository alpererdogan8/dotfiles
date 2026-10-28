#!/bin/bash
STATE_FILE="/tmp/sway-hide-edge-state"

if [[ -f "$STATE_FILE" ]] && [[ "$(cat "$STATE_FILE")" == "on" ]]; then
  # "smart" aynı zamanda smart_borders'ı da açar; yalnızca
  # hide_edge_borders none demek kenarlıkları geri getirmez.
  swaymsg "smart_borders off"
  swaymsg "hide_edge_borders none"
  echo "off" >"$STATE_FILE"
else
  swaymsg "hide_edge_borders --i3 smart"
  echo "on" >"$STATE_FILE"
fi
