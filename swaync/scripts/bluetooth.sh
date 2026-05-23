#!/usr/bin/env bash

THEME="$HOME/.config/rofi/config.rasi"
ROFI_CMD="rofi -dmenu -i -markup-rows -theme $THEME"

get_devices() {
  bluetoothctl devices | while read -r line; do
    mac=$(echo "$line" | awk '{print $2}')
    name=$(echo "$line" | cut -d' ' -f3-)
    echo "$mac|$name"
  done
}

power_state=$(bluetoothctl show | grep "Powered: yes")

if [ -n "$power_state" ]; then
  POWER_TOGGLE="󰂲 Turn Off"
  connected_macs=$(bluetoothctl devices Connected | awk '{print $2}')

  entries=""
  declare -A name_to_mac

  while IFS="|" read -r mac name; do
    if [ -z "$mac" ]; then continue; fi

    if echo "$connected_macs" | grep -q "$mac"; then
      display_name="󰂱  $name <span foreground='#a6da95' weight='bold'>    ✓</span>"
    else
      display_name="󰂯  $name"
    fi

    name_to_mac["$display_name"]="$mac"
    entries+="$display_name\n"
  done <<<"$(get_devices)"
else
  POWER_TOGGLE="󰂯 Turn On"
  entries=""
fi

options="${entries}${POWER_TOGGLE}"
chosen=$(echo -en "$options" | $ROFI_CMD -p "Bluetooth")

if [ -z "$chosen" ]; then
  swaync-client -cp
  exit 0
fi

if [ "$chosen" = "$POWER_TOGGLE" ]; then
  if [ -n "$power_state" ]; then
    bluetoothctl power off >/dev/null
    notify-send "Bluetooth" "Bluetooth is closed"
  else
    bluetoothctl power on >/dev/null
    notify-send "Bluetooth" "Bluetooth is open"
  fi
  swaync-client -cp
  exit 0
fi

if [ -n "${name_to_mac["$chosen"]}" ]; then
  mac="${name_to_mac["$chosen"]}"

  if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
    notify-send "Bluetooth" "Disconnected..."
    bluetoothctl disconnect "$mac" >/dev/null
  else
    notify-send "Bluetooth" "Connected..."
    bluetoothctl connect "$mac" >/dev/null
  fi
  exit 0
fi
