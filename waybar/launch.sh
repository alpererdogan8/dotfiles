#!/usr/bin/env bash
LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/waybar-launch.lock"
if command -v flock >/dev/null 2>&1; then
    exec 9>"$LOCK_FILE"
    flock -n 9 || exit 0
fi

W="$HOME/.config/waybar"
S="$HOME/.config/waybar/style.css"
ASSIGN="$HOME/.config/sway/scripts/kanshi-workspace-assign"

# A crashed previous cycle leaves the lock held by orphaned children
# (waybar / event subscriber / clock tree inherit fd 9). Clear our own
# artifacts here so every launcher start can always take the lock.
pkill -x waybar 2>/dev/null
pkill -f "waybar/scripts/clock_focus_sway.sh" 2>/dev/null
pkill -f "swaymsg -t subscribe -m" 2>/dev/null
sleep 0.3

# Wayland-only session: pin GTK to the wayland backend so a stale
# DISPLAY in the spawning environment (e.g. waybar restarts launched
# from other shells) can never make the bar die on "cannot open :0".
export GDK_BACKEND=wayland

assign_workspaces() {
    local profile
    profile=$(kanshictl status 2>/dev/null | awk '/Current profile:/ {print $3}')
    [[ -x "$ASSIGN" ]] || return 0
    case "$profile" in
        extend|extended|mirror|laptop) "$ASSIGN" "$profile" >/dev/null 2>&1 || true ;;
    esac
}

sw() {
    pkill -x waybar 2>/dev/null
    # Bar başlamadan önce eski saat-dinleyicilerini düşür; crash orphan
    # bırakmasın. pkill kendini eşleştirmez, güvenli.
    pkill -f "waybar/scripts/clock_focus_sway.sh" 2>/dev/null
    sleep 0.3

    PROFILE=$(kanshictl status 2>/dev/null | grep "Current profile:" | awk '{print $3}')
    HDMI_ACTIVE=$(swaymsg -t get_outputs 2>/dev/null | jq 'map(select(.name == "HDMI-A-1" and .active == true)) | length')

    if [[ "$HDMI_ACTIVE" == "0" ]]; then
        waybar -c "$W/config-laptop.jsonc" -s "$S" 9>&- &
        return
    fi

    case "$PROFILE" in
        "extend")
            waybar -c "$W/config-extend.jsonc" -s "$S" 9>&- &
            ;;
        "extended" | "mirror")
            waybar -c "$W/config-extended.jsonc" -s "$S" 9>&- &
            ;;
        "laptop")
            waybar -c "$W/config-laptop.jsonc" -s "$S" 9>&- &
            ;;
        *)
            if [[ "$HDMI_ACTIVE" =~ ^[1-9][0-9]*$ ]]; then
                waybar -c "$W/config-extended.jsonc" -s "$S" 9>&- &
            else
                waybar -c "$W/config-laptop.jsonc" -s "$S" 9>&- &
            fi
            ;;
    esac
}

assign_workspaces
sw

WAYBAR_DEBOUNCE="${WAYBAR_DEBOUNCE:-1.2}"
restart_pid=""

schedule_restart() {
    if [[ -n "$restart_pid" ]]; then
        kill "$restart_pid" 2>/dev/null || true
    fi
    (
        sleep "$WAYBAR_DEBOUNCE"
        assign_workspaces
        sw
    ) &
    restart_pid=$!
}

# Reload on output changes to handle hotplugging
swaymsg -t subscribe -m '["output"]' 9>&- 2>/dev/null | while read -r _; do
    schedule_restart
done
