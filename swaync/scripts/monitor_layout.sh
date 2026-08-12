#!/usr/bin/env bash
# =============================================================================
# monitor_layout.sh — Display layout switcher via Rofi
#
# Presents a Rofi menu with four layout options.
# All transition logic (workspace migration + bar refresh) lives in
# hypr/modules/monitors.lua inside the MonitorProfiles table.
# =============================================================================

ROFI_THEME="$HOME/.config/rofi/config.rasi"

MENU="󰌢  Laptop Only\n󰍹  External Only\n󰍹 󰍹  Mirror\n󰌢 󰍹  Extend"
CHOICE=$(echo -e "$MENU" | rofi -dmenu -i -p "Display" -theme "$ROFI_THEME")

# Exit silently if the user dismissed the menu
[ -z "$CHOICE" ] && exit 0

# Delegate profile switching to the Lua-defined MonitorProfiles module
case "$CHOICE" in
  *"Laptop Only"*)   hyprctl eval 'MonitorProfiles.laptop()'   ;;
  *"External Only"*) hyprctl eval 'MonitorProfiles.external()' ;;
  *"Mirror"*)        hyprctl eval 'MonitorProfiles.mirror()'   ;;
  *"Extend"*)        hyprctl eval 'MonitorProfiles.extend()'   ;;
esac
