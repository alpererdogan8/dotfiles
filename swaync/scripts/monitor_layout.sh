#!/usr/bin/env bash
# =============================================================================
# monitor_layout.sh — Kanshi profile switcher via Rofi
#
# Reads profile names dynamically from the kanshi config file.
# Displays them in a Rofi menu (using the design language from swaync.rasi).
# Switches to the selected profile via `kanshictl switch`.
# =============================================================================

ROFI_THEME="$HOME/.config/rofi/swaync.rasi"
KANSHI_CONFIG="$HOME/.config/kanshi/config"

# ── Guard: kanshi config must exist ─────────────────────────────────────────

if [ ! -f "$KANSHI_CONFIG" ]; then
  notify-send "Monitor Layout" "Kanshi config not found: $KANSHI_CONFIG" -u critical
  exit 1
fi

# ── Parse profile names from kanshi config ───────────────────────────────────
# Lines matching: ^profile <name> {
# Extract the second field (profile name).

mapfile -t PROFILES < <(grep -E '^\s*profile\s+\S+\s*\{' "$KANSHI_CONFIG" \
  | awk '{print $2}')

if [ ${#PROFILES[@]} -eq 0 ]; then
  notify-send "Monitor Layout" "No profiles found in $KANSHI_CONFIG" -u critical
  exit 1
fi

# ── Build display entries with icons ─────────────────────────────────────────
# Map well-known names to Nerd Font icons; unknown profiles get a generic icon.

icon_for_profile() {
  case "$1" in
    extend)   echo "󰌢 󰍹  Extend"     ;;
    extended) echo "󰌢 󰍹  Extended"   ;;
    mirror)   echo "󰍹 󰍹  Mirror"     ;;
    laptop)   echo "󰌢    Laptop Only" ;;
    *)        echo "󰍺    $1"          ;;
  esac
}

entries=""
declare -A ENTRY_TO_PROFILE

for profile in "${PROFILES[@]}"; do
  display=$(icon_for_profile "$profile")
  entries+="${display}\n"
  ENTRY_TO_PROFILE["$display"]="$profile"
done

# ── Show Rofi menu ────────────────────────────────────────────────────────────

CHOSEN=$(echo -e "${entries%\\n}" \
  | rofi -dmenu -i -p "Display" \
         -theme "$ROFI_THEME" \
         -mesg "Active outputs · kanshi profile")

# Close the SwayNC panel if the user dismissed the menu
if [ -z "$CHOSEN" ]; then
  swaync-client -cp
  exit 0
fi

# ── Switch profile ────────────────────────────────────────────────────────────

TARGET_PROFILE="${ENTRY_TO_PROFILE[$CHOSEN]}"

if [ -z "$TARGET_PROFILE" ]; then
  notify-send "Monitor Layout" "Unknown selection: $CHOSEN" -u normal
  exit 1
fi

if kanshictl switch "$TARGET_PROFILE"; then
  notify-send "Monitor Layout" "Switched to profile: $TARGET_PROFILE" \
    -t 2000 -u normal
else
  notify-send "Monitor Layout" \
    "Failed to switch to '$TARGET_PROFILE'. Is kanshi running?" \
    -u critical
fi

swaync-client -cp
