#!/usr/bin/env bash
trap 'pkill -RTMIN+9 waybar 2>/dev/null' EXIT

BT_POWERED=$(bluetoothctl show | grep -c "Powered: yes")

if [[ "$BT_POWERED" -eq 0 ]]; then
  echo '{"text":"󰂲","tooltip":"Bluetooth Off","class":"bt-off"}'
  exit 0
fi

CONNECTED=$(bluetoothctl devices Connected 2>/dev/null)

if [[ -z "$CONNECTED" ]]; then
  echo '{"text":"󰂯","tooltip":"Bluetooth On — No Connected Devices","class":"bt-on"}'
  exit 0
fi

TOOLTIP="Connected Devices"
COUNT=0

while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  MAC=$(echo "$line" | awk '{print $2}')
  NAME=$(echo "$line" | cut -d' ' -f3-)

  UPOWER_PATH=$(upower -e 2>/dev/null |
    grep -i "$(echo "$MAC" | tr ':' '_')" | head -1)

  BATTERY=""
  if [[ -n "$UPOWER_PATH" ]]; then
    BATTERY=$(upower -i "$UPOWER_PATH" 2>/dev/null |
      awk '/percentage/{print $2}')
  fi

  if [[ -z "$BATTERY" ]]; then
    RAW=$(bluetoothctl info "$MAC" 2>/dev/null |
      grep "Battery Percentage" |
      grep -oP '\(\K[0-9]+')
    [[ -n "$RAW" ]] && BATTERY="${RAW}%"
  fi

  if [[ -n "$BATTERY" ]]; then
    NUM=${BATTERY//%/}
    if ((NUM >= 90)); then
      BICON="󰁹"
    elif ((NUM >= 70)); then
      BICON="󰂁"
    elif ((NUM >= 50)); then
      BICON="󰁿"
    elif ((NUM >= 30)); then
      BICON="󰁼"
    elif ((NUM >= 10)); then
      BICON="󰁻"
    else
      BICON="󰂃"
    fi
    TOOLTIP+="\n${BICON}  ${NAME}  ·  ${BATTERY}"
  else
    TOOLTIP+="\n󰂱  ${NAME}"
  fi

  COUNT=$((COUNT + 1))
done <<<"$CONNECTED"

[[ $COUNT -ge 2 ]] && ICON="󰂴" || ICON="󰂱"

printf '{"text":"%s","tooltip":"%s","class":"bt-connected"}' \
  "$ICON" "$TOOLTIP"

pkill -RTMIN+9 waybar
