#!/usr/bin/env bash
# =============================================================================
# wifi.sh — Wi-Fi network manager via Rofi
#
# Displays available SSIDs in a Rofi menu.
# Marks the currently active network with a checkmark.
# Allows toggling Wi-Fi power or connecting to a selected network.
# =============================================================================

THEME="$HOME/.config/rofi/config.rasi"
ROFI_CMD="rofi -dmenu -i -markup-rows -theme $THEME"

# ── Power state ──────────────────────────────────────────────────────────────

status=$(nmcli radio wifi)

if [ "$status" = "enabled" ]; then
  POWER_TOGGLE="󰤮  Wi-Fi Turn Off"

  # Identify the currently connected SSID
  active_ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2 | head -n1)

  # Collect unique non-empty SSIDs visible to the adapter
  bssid_list=$(nmcli -t -f ssid dev wifi | grep -v '^$' | sort -u)

  # Build the display list; highlight the active SSID with a checkmark
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

# ── Show menu ────────────────────────────────────────────────────────────────

options="${entries}${POWER_TOGGLE}"
chosen=$(echo -en "$options" | $ROFI_CMD -p "Wi-Fi")

# Close the SwayNC panel if the user dismissed the menu
if [ -z "$chosen" ]; then
  swaync-client -cp
  exit 0
fi

# ── Power toggle ─────────────────────────────────────────────────────────────

if [ "$chosen" = "$POWER_TOGGLE" ]; then
  if [ "$status" = "enabled" ]; then
    nmcli radio wifi off
    notify-send "Wi-Fi" "Wi-Fi turned off."
  else
    nmcli radio wifi on
    notify-send "Wi-Fi" "Wi-Fi turned on."
  fi
  swaync-client -cp
  exit 0
fi

# ── Network connection ────────────────────────────────────────────────────────

# Strip the Nerd Font icon prefix and any Pango markup from the selection
clicked_ssid=$(echo "$chosen" | sed 's/^󰤨  //' | sed 's/ <span.*//')

if [ -n "$clicked_ssid" ]; then
  notify-send "Wi-Fi" "Connecting to ${clicked_ssid}..."
  nmcli device wifi connect "$clicked_ssid"
  swaync-client -cp
fi
