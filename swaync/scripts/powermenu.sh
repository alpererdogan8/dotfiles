#!/usr/bin/env bash
# =============================================================================
# powermenu.sh — Power/session action menu via Rofi
#
# Displays a Rofi prompt with common session actions:
#   Lock, Logout, Suspend, Reboot, Shutdown
# =============================================================================

lock="󰌾    Lock"
logout="󰍃    Logout"
suspend="󰤄    Suspend"
reboot="󰜉    Reboot"
shutdown="󰐥    Shutdown"

options="$lock\n$logout\n$suspend\n$reboot\n$shutdown"

chosen=$(echo -e "$options" | rofi -dmenu -p "Power:" -layer overlay -theme ~/.config/rofi/config.rasi)

# Close the SwayNC panel if the user dismissed the menu
if [ -z "$chosen" ]; then
  swaync-client -cp
  exit 0
fi

# Execute the selected action
case "$chosen" in
"$lock")
  swaync-client -cp
  swaylock
  ;;
"$logout")
  swaymsg exit
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
