#!/bin/bash

CACHE="${XDG_RUNTIME_DIR:-/tmp}/waybar-clock-cache"
rm -f "$CACHE"
echo "$(date +%s)" > "$CACHE"
echo "" >> "$CACHE"

(
  sock=$(ls "$XDG_RUNTIME_DIR/hypr/"*"/.socket2.sock" 2>/dev/null | head -1)
  [ -z "$sock" ] && exit 1
  socat -u UNIX-CONNECT:"$sock" - 2>/dev/null | while IFS= read -r line; do
    case "$line" in
      activewindow\>\>*)
        title="${line#activewindow>>}"
        title="${title#*,}"
        [ -n "$title" ] && printf '%s\n' "$(date +%s)" > "$CACHE" && printf '%s\n' "$title" >> "$CACHE"
        ;;
    esac
  done
) &
LISTENER_PID=$!
trap 'kill $LISTENER_PID 2>/dev/null; rm -f "$CACHE"; exit' EXIT TERM

exec > >(stdbuf -oL cat)

while true; do
  IFS= read -r last_time < "$CACHE"
  cached_title=$(tail -1 "$CACHE" 2>/dev/null)
  now=$(date +%s)
  elapsed=$((now - last_time))

  if [ "$elapsed" -lt 3 ] && [ -n "$cached_title" ]; then
    truncated=$(printf '%s' "$cached_title" | jq -Rs '.[0:40]')
    tip=$(printf '%s' "Now: $cached_title" | jq -Rs '.')
    printf '{"text": %s, "tooltip": %s}\n' "$truncated" "$tip"
    sleep 0.2
  else
    text=$(date '+%a %d %b  %H:%M' | jq -R '.')
    tip=$(printf '%s\n%s' "$(date '+%H:%M')" "$(date '+%A, %d %B %Y')" | jq -Rs '.')
    printf '{"text": %s, "tooltip": %s}\n' "$text" "$tip"
    sleep 1
  fi
done
