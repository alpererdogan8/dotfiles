#!/bin/bash

BINARY="/usr/local/bin/auto-cpufreq"
CONFIG_FILE="$HOME/.config/swaync/config.json"
MY_COMMAND="$HOME/.local/bin/auto-cpufreq.sh next"

STATE_CACHE="/tmp/auto-cpufreq-state.cache"
WAYBAR_CACHE="/tmp/auto-cpufreq-waybar.json"

ICON_POWERSAVE=$''
ICON_BALANCED=$' '
ICON_PERFORMANCE=$''
ICON_TURBO=$'+'

set_epp() {
  local value="$1"

  for cpu in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    echo "$value" | sudo tee "$cpu" >/dev/null
  done
}

get_state() {
  if [[ -f "$STATE_CACHE" ]] && (($(date +%s) - $(stat -c %Y "$STATE_CACHE") < 2)); then
    cat "$STATE_CACHE"
  else
    local s
    s=$(sudo $BINARY --get-state 2>/dev/null | xargs)
    echo "$s" >"$STATE_CACHE"
    echo "$s"
  fi
}

update_ui() {
  local icon="$1"
  local class="$2"
  local label="$3"

  echo "{\"text\": \"$icon\", \"class\": \"$class\", \"tooltip\": \"Mode: $label\"}" >"$WAYBAR_CACHE"

  pkill -RTMIN+8 waybar &

  notify-send \
    -h int:transient:1 \
    -h string:x-canonical-private-synchronous:power \
    -t 2000 \
    -r 9999 \
    -u normal \
    "Power Mode" "$label" &

  {
    TMP_FILE=$(mktemp)

    jq --arg icon "$icon" --arg cmd "$MY_COMMAND" \
      '(.["widget-config"]["buttons-grid"].actions[] | select(.command == $cmd) | .label) |= $icon' \
      "$CONFIG_FILE" >"$TMP_FILE" && mv "$TMP_FILE" "$CONFIG_FILE"

    swaync-client -R
  } &
}

apply_mode() {
  local mode="$1"

  if [[ "$mode" == "powersave" ]]; then

    sudo $BINARY --force powersave
    sudo $BINARY --turbo never

    set_epp "power"

  elif [[ "$mode" == "balanced" ]]; then

    sudo $BINARY --force powersave
    sudo $BINARY --turbo never

    set_epp "balance_power"

  elif [[ "$mode" == "performance" ]]; then

    sudo $BINARY --force performance
    sudo $BINARY --turbo auto

    set_epp "balance_performance"

  elif [[ "$mode" == "turbo" ]]; then

    sudo $BINARY --force performance
    sudo $BINARY --turbo always

    set_epp "performance"

  fi

  echo "$mode" >"$STATE_CACHE"

  pkill -RTMIN+8 waybar
}

open_rofi() {
  local STATE
  STATE=$(get_state)

  local CURRENT_MARK=" "

  local PS_MARK=""
  local BA_MARK=""
  local PE_MARK=""
  local TU_MARK=""

  if [[ "$STATE" == "powersave" ]]; then
    PS_MARK="$CURRENT_MARK"

  elif [[ "$STATE" == "balanced" ]]; then
    BA_MARK="$CURRENT_MARK"

  elif [[ "$STATE" == "performance" ]]; then
    PE_MARK="$CURRENT_MARK"

  elif [[ "$STATE" == "turbo" ]]; then
    TU_MARK="$CURRENT_MARK"
  fi

  CHOICE=$(printf "%s  Powersave%s\n%s  Balanced%s\n%s  Performance%s\n%s  Turbo%s" \
    "$ICON_POWERSAVE" "$PS_MARK" \
    "$ICON_BALANCED" "$BA_MARK" \
    "$ICON_PERFORMANCE" "$PE_MARK" \
    "$ICON_TURBO" "$TU_MARK" |
    rofi -dmenu -i -p "⚡ Power Mode" -theme ~/.config/rofi/config.rasi)

  [[ -z "$CHOICE" ]] && exit 0

  local NEW_MODE
  local NEW_ICON
  local NEW_LABEL
  local NEW_CLASS

  if [[ "$CHOICE" == *"Powersave"* ]]; then

    NEW_MODE="powersave"
    NEW_ICON="$ICON_POWERSAVE"
    NEW_LABEL="Powersave"
    NEW_CLASS="powersave"

  elif [[ "$CHOICE" == *"Balanced"* ]]; then

    NEW_MODE="balanced"
    NEW_ICON="$ICON_BALANCED"
    NEW_LABEL="Balanced"
    NEW_CLASS="balanced"

  elif [[ "$CHOICE" == *"Performance"* ]]; then

    NEW_MODE="performance"
    NEW_ICON="$ICON_PERFORMANCE"
    NEW_LABEL="Performance"
    NEW_CLASS="performance"

  elif [[ "$CHOICE" == *"Turbo"* ]]; then

    NEW_MODE="turbo"
    NEW_ICON="$ICON_TURBO"
    NEW_LABEL="Turbo"
    NEW_CLASS="turbo"

  else
    exit 0
  fi

  echo "$NEW_MODE" >"$STATE_CACHE"

  update_ui "$NEW_ICON" "$NEW_CLASS" "$NEW_LABEL"

  {
    apply_mode "$NEW_MODE"
  } &
}

if [[ "$1" == "open" ]]; then
  open_rofi
  exit 0
fi

if [[ -f "$WAYBAR_CACHE" ]]; then

  cat "$WAYBAR_CACHE"

  {
    REAL_STATE=$(sudo $BINARY --get-state 2>/dev/null | xargs)
    echo "$REAL_STATE" >"$STATE_CACHE"
  } &

  exit 0
fi

STATE=$(get_state)

ICON="$ICON_BALANCED"
CLASS="balanced"
TOOLTIP="Balanced"

if [[ "$STATE" == "powersave" ]]; then

  ICON="$ICON_POWERSAVE"
  CLASS="powersave"
  TOOLTIP="Powersave"

elif [[ "$STATE" == "performance" ]]; then

  ICON="$ICON_PERFORMANCE"
  CLASS="performance"
  TOOLTIP="Performance"

elif [[ "$STATE" == "turbo" ]]; then

  ICON="$ICON_TURBO"
  CLASS="turbo"
  TOOLTIP="Turbo"

fi

echo "{\"text\": \"$ICON\", \"class\": \"$CLASS\", \"tooltip\": \"Mode: $TOOLTIP\"}"
