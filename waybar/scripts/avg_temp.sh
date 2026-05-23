#!/bin/bash

sum=0
count=0
tooltip=""

for hwmon in /sys/class/hwmon/hwmon*; do
  if grep -q "Core" "$hwmon"/temp*_label 2>/dev/null; then
    for label_file in "$hwmon"/temp*_label; do
      if grep -q "Core" "$label_file"; then
        read -r name <"$label_file"
        input_file="${label_file%_label}_input"
        if [ -f "$input_file" ]; then
          read -r raw_val <"$input_file"
          val=$((raw_val / 1000))
          sum=$((sum + val))
          count=$((count + 1))
          tooltip="${tooltip}${name}: ${val}°C\\n"
        fi
      fi
    done
    break
  fi
done

if [ "$count" -gt 0 ]; then
  avg=$((sum / count))
  tooltip=${tooltip%??}
  printf '{"text": " %d°C", "tooltip": "%s"}\n' "$avg" "$tooltip"
else
  printf '{"text": "N/A", "tooltip": "Core sensör dosyaları bulunamadı."}\n'
fi
