#!/bin/bash

TIMEOUT=3  # Window name display duration (seconds)

CACHE="${XDG_RUNTIME_DIR:-/tmp}/waybar-clock-cache"

# Initial write
printf '%s\n\n' "$(date +%s)" > "$CACHE"

# Get HYPRLAND_INSTANCE_SIGNATURE from env directly, no glob
SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

(
  if [ ! -S "$SOCK" ]; then
    echo "waybar-clock: socket not found: $SOCK" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$CACHE")"

  write_cache() {
    local title="$1"
    [ -z "$title" ] && return
    printf '%s\n%s\n' "$(date +%s)" "$title" > "$CACHE"
  }

  socat -U - UNIX-CONNECT:"$SOCK" 2>/dev/null | while IFS= read -r line; do
    case "$line" in
      activewindow\>\>*)
        title="${line#*>>}"
        title="${title#*,}"
        write_cache "$title"
        ;;
      workspace\>\>*)
        # Query active window on workspace switch
        active_title=$(hyprctl activewindow -j 2>/dev/null | jq -r '.title // empty' 2>/dev/null)
        [ -n "$active_title" ] && write_cache "$active_title"
        ;;
    esac
  done
) &
LISTENER_PID=$!

cleanup() {
  local children
  children=$(pgrep -P "$LISTENER_PID" 2>/dev/null)
  for child in $children; do
    kill "$child" 2>/dev/null
    local grandchildren
    grandchildren=$(pgrep -P "$child" 2>/dev/null)
    for gc in $grandchildren; do kill "$gc" 2>/dev/null; done
  done
  kill "$LISTENER_PID" 2>/dev/null
  rm -f "$CACHE"
  exit
}
trap cleanup EXIT TERM INT

while true; do
  last_time=$(head -1 "$CACHE" 2>/dev/null)
  cached_title=$(sed -n '2p' "$CACHE" 2>/dev/null)
  now=$(date +%s)
  elapsed=$(( now - ${last_time:-0} ))

  if [ "$elapsed" -lt "$TIMEOUT" ] && [ -n "$cached_title" ]; then
    short=$(printf '%s' "$cached_title" | cut -c1-40)
    text=$(printf '%s' "$short" | jq -Rs '.')
    tip=$(printf 'Now: %s' "$cached_title" | jq -Rs '.')
    printf '{"text": %s, "tooltip": %s}\n' "$text" "$tip"
    sleep 0.2
  else
    text=$(LC_ALL=en_US.UTF-8 date '+%d %B %Y - %H:%M' | jq -R '.')
    tip=$(printf '%s\n%s' \
      "$(LC_ALL=en_US.UTF-8 date '+%H:%M')" \
      "$(LC_ALL=en_US.UTF-8 date '+%A, %d %B %Y')" | jq -Rs '.')
    printf '{"text": %s, "tooltip": %s}\n' "$text" "$tip"
    sleep 1
  fi
done
