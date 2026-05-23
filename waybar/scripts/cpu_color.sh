#!/bin/bash

get_level() {
  local val=$1
  if [ "$val" -le 20 ]; then echo 1;
  elif [ "$val" -le 40 ]; then echo 2;
  elif [ "$val" -le 60 ]; then echo 3;
  elif [ "$val" -le 80 ]; then echo 4;
  else echo 5;
  fi
}

usage=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')
[ -z "$usage" ] && usage=0

level=$(get_level "$usage")

printf '{"text": "󰍛", "tooltip": "CPU  %d%%", "class": "level-%d"}\n' "$usage" "$level"