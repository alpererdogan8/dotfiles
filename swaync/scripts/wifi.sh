#!/usr/bin/env bash

THEME="$HOME/.config/rofi/config.rasi"
ROFI_CMD="rofi -dmenu -i -markup-rows -theme $THEME"

status=$(nmcli radio wifi)
if [ "$status" = "enabled" ]; then
  POWER_TOGGLE="󰤮  Wi-Fi Turn Off"

  # Get active connection SSID
  active_ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2 | head -n1)

  # Get list of unique SSIDs ignoring empty ones
  bssid_list=$(nmcli -t -f ssid dev wifi | grep -v '^$' | sort -u)

  entries=""
  while IFS= read -r ssid; do
    if [ "$ssid" = "$active_ssid" ]; then
      display_name="󰤨  ${ssid} <span foreground='#a6da95' weight='bold'>    ✓</span>"
    else
      display_name="󰤨  ${ssid}"
    fi
    entries+="${display_name}\n"
  done <<<"$bssid_list"
else
  POWER_TOGGLE="󰤨  Wi-Fi Turn On"
  entries=""
fi

options="${entries}${POWER_TOGGLE}"
chosen=$(echo -en "$options" | $ROFI_CMD -p "Wi-Fi")

# If user clicked outside or hit Escape
if [ -z "$chosen" ]; then
  swaync-client -cp
  exit 0
fi

if [ "$chosen" = "$POWER_TOGGLE" ]; then
  if [ "$status" = "enabled" ]; then
    nmcli radio wifi off
    notify-send "Wi-Fi" "Wi-Fi turn off."
  else
    nmcli radio wifi on
    notify-send "Wi-Fi" "Wi-Fi turn on."
  fi
  swaync-client -cp
  exit 0
fi

# A network was chosen
clicked_ssid=$(echo "$chosen" | sed 's/^󰤨  //' | sed 's/ <span.*//')
if [ -n "$clicked_ssid" ]; then
  notify-send "Wi-Fi" "Connect $clicked_ssid..."
  nmcli device wifi connect "$clicked_ssid"
  swaync-client -cp
fi
