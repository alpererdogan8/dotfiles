#!/bin/bash

# ── Color definitions ───────────────────────────────────────────
RED='\033[0;31m'
YEL='\033[1;33m'
GRN='\033[0;32m'
CYN='\033[0;36m'
BLD='\033[1m'
RST='\033[0m'

CPU0="/sys/devices/system/cpu/cpu0/cpufreq"

# ── EPP (Energy Performance Preference) ─────────────────────────
epp=$(cat "$CPU0/energy_performance_preference" 2>/dev/null || echo "N/A")

# ── Governor ────────────────────────────────────────────────────
gov=$(cat "$CPU0/scaling_governor" 2>/dev/null || echo "N/A")

# ── Turbo Boost ─────────────────────────────────────────────────
if [[ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]]; then
  no_turbo=$(cat /sys/devices/system/cpu/intel_pstate/no_turbo)
  turbo=$([[ "$no_turbo" == "0" ]] && echo "On" || echo "Off")
elif [[ -f /sys/devices/system/cpu/cpufreq/boost ]]; then
  boost=$(cat /sys/devices/system/cpu/cpufreq/boost)
  turbo=$([[ "$boost" == "1" ]] && echo "On" || echo "Off")
else
  turbo="N/A"
fi

# ── Cached mode ──────────────────────────────────────────────────
cache_state=$(cat /tmp/auto-cpufreq-state.cache 2>/dev/null || echo "—")

# ── Header ───────────────────────────────────────────────────────
echo -e "\n${BLD}${CYN}══════════════════════════════${RST}"
echo -e "${BLD}  CPU Power Status${RST}"
echo -e "${BLD}${CYN}══════════════════════════════${RST}"

printf "  %-18s %s\n" "Mode (cached):"  "$cache_state"
printf "  %-18s %s\n" "Governor:"       "$gov"
printf "  %-18s %s\n" "EPP:"            "$epp"
printf "  %-18s %s\n" "Turbo Boost:"    "$turbo"

# ── Min / Max / Current frequency ───────────────────────────────
min_khz=$(cat "$CPU0/scaling_min_freq" 2>/dev/null)
max_khz=$(cat "$CPU0/scaling_max_freq" 2>/dev/null)

[[ -n "$min_khz" ]] && printf "  %-18s %s MHz\n" "Min Frequency:" "$((min_khz / 1000))"
[[ -n "$max_khz" ]] && printf "  %-18s %s MHz\n" "Max Frequency:" "$((max_khz / 1000))"

# ── Per-core frequencies ─────────────────────────────────────────
echo -e "${CYN}──────────────────────────────${RST}"
echo -e "  ${BLD}Per-core frequencies:${RST}"

for freq_file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq; do
  core=$(echo "$freq_file" | grep -oP 'cpu\d+')
  freq_mhz=$(( $(cat "$freq_file") / 1000 ))

  if   (( freq_mhz >= 3000 )); then color=$RED
  elif (( freq_mhz >= 1800 )); then color=$YEL
  else                               color=$GRN
  fi

  printf "    %-8s ${color}%4d MHz${RST}\n" "$core:" "$freq_mhz"
done

# ── Temperatures ─────────────────────────────────────────────────
echo -e "${CYN}──────────────────────────────${RST}"
echo -e "  ${BLD}Temperatures:${RST}"

found_temp=false
for zone in /sys/class/thermal/thermal_zone*/; do
  type=$(cat "$zone/type" 2>/dev/null)
  temp=$(cat "$zone/temp" 2>/dev/null)
  [[ -z "$temp" ]] && continue

  temp_c=$(( temp / 1000 ))
  [[ "$type" =~ ^(x86_pkg|cpu|CPU|acpitz|coretemp) ]] || continue

  (( temp_c >= 80 )) && color=$RED || \
  (( temp_c >= 60 )) && color=$YEL || color=$GRN

  printf "    %-16s ${color}%2d°C${RST}\n" "$type:" "$temp_c"
  found_temp=true
done

$found_temp || echo "    (no temperature data found)"

echo -e "${BLD}${CYN}══════════════════════════════${RST}\n"