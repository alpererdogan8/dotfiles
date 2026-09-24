#!/bin/bash
# Waybar custom module: battery icon + tooltip ("46% remaining" / "5.5 W").
# Waybar calls this once per interval; state is kept in $STATE.
#
# This EC exposes neither power_now nor current_now, and charge_now only
# changes in coarse, irregular steps. So power is derived from *real* charge
# steps instead of from two arbitrary polls:
#     W = dQ * V_avg / dt      (dQ = charge drop between two change points)
# V is averaged over the window. Never difference Q*V: voltage sags under
# load and moves with state of charge, which leaks in as fake watts.

BAT=${BAT:-/sys/class/power_supply/BAT1}
STATE="${XDG_RUNTIME_DIR:-/tmp}/waybar-battery-watt"
MIN_WINDOW=60   # s: shortest span between two charge steps to trust
MAX_AGE=300     # s: hide watts if charge_now has not changed for this long
MAX_POINTS=16   # charge-change points kept in the state file
STATE_DIR=$(dirname "$STATE")
mkdir -p "$STATE_DIR" 2>/dev/null || true

battery_unavailable() {
  printf '{"text":"","tooltip":"Battery unavailable","class":"unknown"}\n'
  exit 0
}

if [[ ! -d "$BAT" ]]; then
  BAT=""
  for candidate in /sys/class/power_supply/*; do
    if [[ -r "$candidate/type" && "$(<"$candidate/type")" == "Battery" ]]; then
      BAT="$candidate"
      break
    fi
  done
fi

if [[ -z "$BAT" || ! -r "$BAT/charge_now" || ! -r "$BAT/voltage_now" || ! -r "$BAT/capacity" || ! -r "$BAT/status" ]]; then
  battery_unavailable
fi

now=$(date +%s)
c2=$(<"$BAT/charge_now")
v2=$(<"$BAT/voltage_now")
cap=$(<"$BAT/capacity")
raw_status=$(<"$BAT/status")
if [[ ! "$c2" =~ ^[0-9]+$ || ! "$v2" =~ ^[0-9]+$ || ! "$cap" =~ ^[0-9]+$ ]]; then
  battery_unavailable
fi
raw_status="${raw_status:-Unknown}"

online=0
for d in /sys/class/power_supply/*; do
  [[ -r "$d/type" && -r "$d/online" ]] || continue
  if [[ "$(<"$d/type")" == "Mains" ]]; then
    online=$(<"$d/online")
  fi
done

idx=$((cap / 10))
(( idx > 9 )) && idx=9
(( idx < 0 )) && idx=0
# Font Awesome battery glyphs as raw UTF-8 bytes (works in any locale)
icons=($'\xef\x89\x84' $'\xef\x89\x84' $'\xef\x89\x83' $'\xef\x89\x83' $'\xef\x89\x83' $'\xef\x89\x83' $'\xef\x89\x82' $'\xef\x89\x81' $'\xef\x89\x81' $'\xef\x89\x81')
icon="${icons[$idx]}"

if [[ "$raw_status" == "Full" || ( "$raw_status" == "Charging" && "$cap" -eq 100 ) ]]; then
  icon=$'\xef\x89\x80'
  class="full"
elif [[ "$raw_status" == "Charging" ]]; then
  icon="${icon}󱐋"
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

# Prints watts (one decimal) or nothing when there is not enough data yet.
calc_watts() {
  local last_run="" last_status="" t c v i f=-1 last vsum=0
  local -a T=() C=() V=()
  local num='^[0-9]+$'

  if [[ -r "$STATE" ]]; then
    {
      read -r last_run last_status
      while read -r t c v; do
        [[ $t =~ $num && $c =~ $num && $v =~ $num ]] && { T+=("$t"); C+=("$c"); V+=("$v"); }
      done
    } < "$STATE"
  fi
  [[ $last_run =~ $num ]] || last_run=""

  # First run, long gap (suspend), or status change: start over.
  # T=0 marks the start point: its real time is unknown, so it is never used.
  if [[ -z "$last_run" ]] || (( now - last_run > 120 )) \
     || [[ "$last_status" != "$raw_status" ]] || (( ${#T[@]} == 0 )); then
    T=(0); C=("$c2"); V=("$v2")
  elif [[ "${C[-1]}" != "$c2" ]]; then
    T+=("$now"); C+=("$c2"); V+=("$v2")
  fi
  while (( ${#T[@]} > MAX_POINTS )); do T=("${T[@]:1}"); C=("${C[@]:1}"); V=("${V[@]:1}"); done

  {
    echo "$now $raw_status"
    for i in "${!T[@]}"; do echo "${T[i]} ${C[i]} ${V[i]}"; done
  } > "$STATE"

  # Newest start point that gives a window of at least MIN_WINDOW seconds.
  last=$(( ${#T[@]} - 1 ))
  for (( i = last - 1; i >= 0; i-- )); do
    (( T[i] == 0 )) && break
    if (( T[last] - T[i] >= MIN_WINDOW )); then f=$i; break; fi
  done
  (( f >= 0 )) || return 0
  (( now - T[last] <= MAX_AGE )) || return 0

  for (( i = f; i <= last; i++ )); do vsum=$(( vsum + V[i] )); done
  awk -v dq="$(( C[f] - C[last] ))" -v v="$(( vsum / (last - f + 1) ))" \
      -v dt="$(( T[last] - T[f] ))" \
      'BEGIN { if (dq < 0) dq = -dq; printf "%.1f", dq * v / 1e12 / (dt / 3600) }'
}

watts=$(calc_watts 2>/dev/null || true)
tooltip="${cap}% remaining"
[[ -n "$watts" ]] && tooltip="${cap}% remaining\\n${watts} W"

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$icon" "$tooltip" "$class"
