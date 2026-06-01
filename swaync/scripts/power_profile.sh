#!/bin/bash

ROFI_CONFIG="$HOME/.config/rofi/config.rasi"
SWAYNC_CONFIG="$HOME/.config/swaync/config.json"

set_profile() {
    local profile="$1"
    local label="$2"

    powerprofilesctl set "$profile"

    local tmp
    tmp=$(mktemp)
    jq --arg label "$label" \
        '(.["widget-config"]["buttons-grid"]["actions"][] |
        select(.command | contains("power-menu")) | .label) = $label' \
        "$SWAYNC_CONFIG" > "$tmp" && mv "$tmp" "$SWAYNC_CONFIG"

    swaync-client --reload-config
    notify-send "Power Profile" "$label" -t 2000 -u normal
}

chosen=$(printf "󱐋 Performance\n    Balanced\n  Power Saver" | \
   rofi -dmenu -i -markup-rows -theme "$ROFI_CONFIG" -no-custom)

case "$chosen" in
    *"Performance"*)  set_profile "performance" "Performance" ;;
    *"Balanced"*)     set_profile "balanced"    "Balanced"    ;;
    *"Power Saver"*)  set_profile "power-saver" "Power Saver" ;;
esac