#!/usr/bin/env bash
# =============================================================================
# power_profile.sh — CPU power profile switcher via Rofi
#
# Presents a Rofi menu with three power profiles (Performance / Balanced /
# Power Saver). On selection it:
#   1. Activates the profile via powerprofilesctl
#   2. Updates the button label in the SwayNC config
#   3. Reloads the SwayNC config
#   4. Sends a desktop notification
# =============================================================================

ROFI_CONFIG="$HOME/.config/rofi/swaync.rasi"

set_profile() {
  local profile="$1"
  local label="$2"

  if ! powerprofilesctl set "$profile"; then
    notify-send -u critical "Power Profile" "Failed to set profile: $label" -t 3000
    return 1
  fi

  notify-send "Power Profile" "$label" -t 2000 -u normal
}

# Show the profile selection menu
chosen=$(printf "󱐋  Performance\n󰾅  Balanced\n󰤄  Power Saver" | \
  rofi -dmenu -i -markup-rows -theme "$ROFI_CONFIG" -no-custom)

# Map the selection to a profile identifier
case "$chosen" in
  *"Performance"*) set_profile "performance" "Performance" ;;
  *"Balanced"*)    set_profile "balanced"    "Balanced"    ;;
  *"Power Saver"*) set_profile "power-saver" "Power Saver" ;;
esac