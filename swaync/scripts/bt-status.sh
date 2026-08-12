#!/usr/bin/env bash
# =============================================================================
# bt-status.sh — Bluetooth status reporter for Waybar
#
# Outputs a JSON object consumed by a Waybar custom module.
# Shows connection state, device names, and battery levels (if available).
# Triggers a Waybar signal (RTMIN+9) on exit to refresh the module.
# =============================================================================

trap 'pkill -RTMIN+9 waybar 2>/dev/null' EXIT

# ── Power state ──────────────────────────────────────────────────────────────

BT_POWERED=$(bluetoothctl show | grep -c "Powered: yes")

if [[ "$BT_POWERED" -eq 0 ]]; then
  echo '{"text":"󰂲","tooltip":"Bluetooth Off","class":"bt-off"}'
  exit 0
fi

# ── Connected devices ────────────────────────────────────────────────────────

CONNECTED=$(bluetoothctl devices Connected 2>/dev/null)

if [[ -z "$CONNECTED" ]]; then
  echo '{"text":"󰂯","tooltip":"Bluetooth On — No Connected Devices","class":"bt-on"}'
  exit 0
fi

TOOLTIP="Connected Devices"
COUNT=0

# Iterate over each connected device and collect battery info
while IFS= read -r line; do
  [[ -z "$line" ]] && continue

  MAC=$(echo "$line" | awk '{print $2}')
  NAME=$(echo "$line" | cut -d' ' -f3-)

  # Try to get battery percentage from UPower first
  UPOWER_PATH=$(upower -e 2>/dev/null |
    grep -i "$(echo "$MAC" | tr ':' '_')" | head -1)

  BATTERY=""
  if [[ -n "$UPOWER_PATH" ]]; then
    BATTERY=$(upower -i "$UPOWER_PATH" 2>/dev/null |
      awk '/percentage/{print $2}')
  fi

  # Fall back to bluetoothctl battery info if UPower has no data
  if [[ -z "$BATTERY" ]]; then
    RAW=$(bluetoothctl info "$MAC" 2>/dev/null |
      grep "Battery Percentage" |
      grep -oP '\(\K[0-9]+')
    [[ -n "$RAW" ]] && BATTERY="${RAW}%"
  fi

  # Choose a battery icon based on percentage
  if [[ -n "$BATTERY" ]]; then
    NUM=${BATTERY//%/}
    if   ((NUM >= 90)); then BICON="󰁹"
    elif ((NUM >= 70)); then BICON="󰂁"
    elif ((NUM >= 50)); then BICON="󰁿"
    elif ((NUM >= 30)); then BICON="󰁼"
    elif ((NUM >= 10)); then BICON="󰁻"
    else                     BICON="󰂃"
    fi
    TOOLTIP+="\n${BICON}  ${NAME}  ·  ${BATTERY}"
  else
    TOOLTIP+="\n󰂱  ${NAME}"
  fi

  COUNT=$((COUNT + 1))
done <<<"$CONNECTED"

# Use a different icon when multiple devices are connected
[[ $COUNT -ge 2 ]] && ICON="󰂴" || ICON="󰂱"

printf '{"text":"%s","tooltip":"%s","class":"bt-connected"}' \
  "$ICON" "$TOOLTIP"

# Explicitly refresh Waybar after outputting the status
pkill -RTMIN+9 waybar
