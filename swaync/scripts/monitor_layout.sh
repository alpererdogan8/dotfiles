#!/bin/bash
# Monitör düzeni seçici. Tüm geçiş mantığı (workspace taşıma + bar yenileme)
# hypr/modules/monitors.lua içindeki MonitorProfiles tablosunda yaşar.
MENU="󰌢  Laptop Only\n󰍹  External Only\n󰍹 󰍹  Mirror\n󰌢 󰍹  Extend"
CHOICE=$(echo -e "$MENU" | rofi -dmenu -i -p "Display" -theme ~/.config/rofi/config.rasi)

[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
*"Laptop Only"*) hyprctl eval 'MonitorProfiles.laptop()' ;;
*"External Only"*) hyprctl eval 'MonitorProfiles.external()' ;;
*"Mirror"*) hyprctl eval 'MonitorProfiles.mirror()' ;;
*"Extend"*) hyprctl eval 'MonitorProfiles.extend()' ;;
esac
