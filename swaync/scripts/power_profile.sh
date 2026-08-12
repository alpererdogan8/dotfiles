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

ROFI_CONFIG="$HOME/.config/rofi/config.rasi"
SWAYNC_CONFIG="$HOME/.config/swaync/config.json"

# Apply the given power profile and update the corresponding SwayNC button label
set_profile() {
  local profile="$1"  # powerprofilesctl profile identifier
  local label="$2"    # human-readable label shown in the SwayNC button

  powerprofilesctl set "$profile"

  # Atomically update the button label in the SwayNC JSON config
  local tmp
  tmp=$(mktemp)
  jq --arg label "$label" \
    '(.[\"widget-config\"][\"buttons-grid\"][\"actions\"][] |
    select(.command | contains("power_profile")) | .label) = $label' \
    "$SWAYNC_CONFIG" > "$tmp" && mv "$tmp" "$SWAYNC_CONFIG"

  swaync-client --reload-config
  notify-send "Power Profile" "$label" -t 2000 -u normal
}

# Show the profile selection menu
chosen=$(printf "󱐋 Performance\n    Balanced\n  Power Saver" | \
  rofi -dmenu -i -markup-rows -theme "$ROFI_CONFIG" -no-custom)

# Map the selection to a profile identifier
case "$chosen" in
  *"Performance"*) set_profile "performance" "Performance" ;;
  *"Balanced"*)    set_profile "balanced"    "Balanced"    ;;
  *"Power Saver"*) set_profile "power-saver" "Power Saver" ;;
esac