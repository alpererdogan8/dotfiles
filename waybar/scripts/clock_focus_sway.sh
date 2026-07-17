#!/bin/bash

TIMEOUT=3  # Window name display duration (seconds)

CACHE="${XDG_RUNTIME_DIR:-/tmp}/waybar-clock-cache"

# Initial write
printf '%s\n\n' "$(date +%s)" > "$CACHE"

(
  mkdir -p "$(dirname "$CACHE")"

  write_cache() {
    local title="$1"
    [ -z "$title" ] && return
    printf '%s\n%s\n' "$(date +%s)" "$title" > "$CACHE"
  }

  # Subscribe to sway window and workspace events (-m = monitor mode, keeps listening)
  swaymsg -t subscribe -m '["window","workspace"]' 2>/dev/null | while IFS= read -r event; do
    change=$(printf '%s' "$event" | jq -r '.change // empty' 2>/dev/null)

    case "$change" in
      focus|title|new)
        # Window events carry .container.name
        title=$(printf '%s' "$event" | jq -r '.container.name // empty' 2>/dev/null)
        if [ -n "$title" ]; then
          write_cache "$title"
        else
          # Workspace switch — query focused window from tree
          active_title=$(swaymsg -t get_tree 2>/dev/null | \
            jq -r 'recurse(.nodes[]?, .floating_nodes[]?) | select(.focused == true and .type == "con") | .name // empty' 2>/dev/null | head -1)
          [ -n "$active_title" ] && write_cache "$active_title"
        fi
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
