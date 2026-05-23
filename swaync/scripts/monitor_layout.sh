#!/bin/bash
MENU="󰌢  Laptop Only\n󰍹  External Only\n󰍹 󰍹  Mirror\n󰌢 󰍹  Extend"
CHOICE=$(echo -e "$MENU" | rofi -dmenu -i -p "Display" -theme ~/.config/rofi/config.rasi)

if [[ "$CHOICE" == *"Laptop Only"* ]]; then
  hyprctl eval 'laptopOnly()'
elif [[ "$CHOICE" == *"External Only"* ]]; then
  hyprctl eval 'externalOnly()'
elif [[ "$CHOICE" == *"Mirror"* ]]; then
  hyprctl eval 'mirrorMon()'
elif [[ "$CHOICE" == *"Extend"* ]]; then
  hyprctl eval 'extendMon()'
fi
