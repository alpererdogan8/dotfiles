#!/usr/bin/env bash
# =============================================================================
# bluetooth.sh — Bluetooth device manager via Rofi
#
# Displays paired Bluetooth devices in a Rofi menu.
# Allows connecting/disconnecting individual devices and toggling power.
# =============================================================================

THEME="$HOME/.config/rofi/swaync.rasi"
ROFI_CMD="rofi -dmenu -i -markup-rows -theme $THEME"

# Returns a list of paired devices as "MAC|Name" pairs (one per line)
get_devices() {
  bluetoothctl devices | while read -r line; do
    mac=$(echo "$line" | awk '{print $2}')
    name=$(echo "$line" | cut -d' ' -f3-)
    echo "$mac|$name"
  done
}

# Check whether Bluetooth adapter is currently powered on
power_state=$(bluetoothctl show | grep "Powered: yes")

if [ -n "$power_state" ]; then
  POWER_TOGGLE="󰂲 Turn Off"
  connected_macs=$(bluetoothctl devices Connected | awk '{print $2}')

  entries=""
  declare -A name_to_mac

  # Build the device list; mark already-connected devices with a checkmark
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

# Close the panel if the user dismissed the menu
if [ -z "$chosen" ]; then
  swaync-client -cp
  exit 0
fi

# Handle power toggle selection
if [ "$chosen" = "$POWER_TOGGLE" ]; then
  if [ -n "$power_state" ]; then
    bluetoothctl power off >/dev/null
    notify-send "Bluetooth" "Bluetooth turned off"
  else
    bluetoothctl power on >/dev/null
    notify-send "Bluetooth" "Bluetooth turned on"
  fi
  swaync-client -cp
  exit 0
fi

# Handle device connect / disconnect
if [ -n "${name_to_mac["$chosen"]}" ]; then
  mac="${name_to_mac["$chosen"]}"

  if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
    notify-send "Bluetooth" "Disconnecting..."
    bluetoothctl disconnect "$mac" >/dev/null
  else
    notify-send "Bluetooth" "Connecting..."
    bluetoothctl connect "$mac" >/dev/null
  fi
  exit 0
fi
