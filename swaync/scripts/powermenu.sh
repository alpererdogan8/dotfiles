#!/bin/bash

lock="󰌾    Lock"
logout="󰍃    Logout"
suspend="󰤄    Suspend"
reboot="󰜉    Reboot"
shutdown="󰐥    Shutdown"

options="$lock\n$logout\n$suspend\n$reboot\n$shutdown"

chosen=$(echo -e "$options" | rofi -dmenu -p -layer overlay "Güç:" -theme ~/.config/rofi/config.rasi)

if [ -z "$chosen" ]; then
    swaync-client -cp
    exit 0
fi

case "$chosen" in
    "$lock") 
        swaync-client -cp
        swaylock 
        ;;
    "$logout")
        hyprctl dispatch exit
        ;;
    "$suspend")
        systemctl suspend
        ;;
    "$reboot")
        systemctl reboot
        ;;
    "$shutdown")
        systemctl poweroff
        ;;
esac