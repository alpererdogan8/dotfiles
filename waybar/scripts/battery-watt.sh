#!/bin/bash
# One shot. Waybar calls this on its interval.
# Tooltip is two lines: "46% remaining" then "5.5 W".
# The icon matches the battery module so this widget can replace it.
BAT=/sys/class/power_supply/BAT1
STATE="${XDG_RUNTIME_DIR:-/tmp}/waybar-battery-watt"

now=$(date +%s)
c2=$(cat "$BAT/charge_now")
v2=$(cat "$BAT/voltage_now")
cap=$(cat "$BAT/capacity")
raw_status=$(cat "$BAT/status")

online=0
for d in /sys/class/power_supply/*; do
  [[ -r "$d/type" && -r "$d/online" ]] || continue
  if [[ "$(cat "$d/type")" == "Mains" ]]; then
    online=$(cat "$d/online")
  fi
done

idx=$((cap / 10))
(( idx > 9 )) && idx=9
(( idx < 0 )) && idx=0
icons=($'\uf244' $'\uf244' $'\uf243' $'\uf243' $'\uf243' $'\uf243' $'\uf242' $'\uf241' $'\uf241' $'\uf241')
icon="${icons[$idx]}"

if [[ "$raw_status" == "Full" || ( "$raw_status" == "Charging" && "$cap" -eq 100 ) ]]; then
  icon=$'\uf240'
  class="full"
elif [[ "$raw_status" == "Charging" ]]; then
  icon="${icon}"$'\uf0e7'
  class="charging"
elif [[ "$raw_status" == "Not charging" && "$online" == "1" ]]; then
  class="plugged"
elif (( cap <= 39 )); then
  class="critical"
elif (( cap <= 59 )); then
  class="warning"
elif (( cap <= 69 )); then
  class="yellow"
elif (( cap <= 79 )); then
  class="normal"
else
  class="high"
fi

tooltip="${cap}% remaining"
if [[ -r "$STATE" ]]; then
  read -r t1 c1 v1 < "$STATE" || true
  if [[ -n "${t1:-}" && -n "${c1:-}" && -n "${v1:-}" && "$now" -gt "$t1" ]]; then
    watts=$(awk -v c1="$c1" -v v1="$v1" -v c2="$c2" -v v2="$v2" -v t1="$t1" -v t2="$now" 'BEGIN {
      dt = t2 - t1
      if (dt <= 0) exit
      e1 = c1 * v1 / 1e12
      e2 = c2 * v2 / 1e12
      w = (e1 - e2) / (dt / 3600)
      if (w < 0) w = -w
      printf "%.1f", w
    }')
    if [[ -n "$watts" ]]; then
      tooltip="${cap}% remaining\\n${watts} W"
    fi
  fi
fi

printf '%s %s %s\n' "$now" "$c2" "$v2" > "$STATE"
printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$icon" "$tooltip" "$class"
