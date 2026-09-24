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

chosen=$(echo -e "$options" | rofi -dmenu -p "Power:" -layer overlay -theme ~/.config/rofi/swaync.rasi)

# Close the SwayNC panel if the user dismissed the menu
if [ -z "$chosen" ]; then
  swaync-client -cp
  exit 0
fi

confirm() {
  local prompt="$1"
  local answer
  answer=$(printf '%s\n' 'No' 'Yes' | rofi -dmenu -p "$prompt" -theme ~/.config/rofi/swaync.rasi -no-custom)
  [[ "$answer" == "Yes" ]]
}

# Execute the selected action
case "$chosen" in
"$lock")
  swaync-client -cp
  swaylock
  ;;
"$logout")
  confirm "Log out?" && swaymsg exit || true
  ;;
"$suspend")
  confirm "Suspend?" && systemctl suspend || true
  ;;
"$reboot")
  confirm "Reboot?" && systemctl reboot || true
  ;;
"$shutdown")
  confirm "Shut down?" && systemctl poweroff || true
  ;;
esac
