#!/usr/bin/env bash
W="$HOME/dotfiles/waybar"
S="$HOME/.config/waybar/style.css"

sw() {
    pkill -x waybar 2>/dev/null
    sleep 0.3
    
    # Get current kanshi profile
    PROFILE=$(kanshictl status 2>/dev/null | grep "Current profile:" | awk '{print $3}')
    
    case "$PROFILE" in
        "extend")
            # HDMI only (1-10 on HDMI)
            waybar -c "$W/config-extend.jsonc" -s "$S" &
            ;;
        "extended" | "mirror")
            # Dual monitors (1-5 HDMI, 6-10 eDP)
            waybar -c "$W/config-extended.jsonc" -s "$S" &
            ;;
        "laptop")
            # Laptop only (1-10 on eDP)
            waybar -c "$W/config-laptop.jsonc" -s "$S" &
            ;;
        *)
            # Fallback
            HDMI_ACTIVE=$(swaymsg -t get_outputs 2>/dev/null | jq 'map(select(.name == "HDMI-A-1" and .active == true)) | length')
            if [ "$HDMI_ACTIVE" -gt 0 ]; then
                waybar -c "$W/config-extended.jsonc" -s "$S" &
            else
                waybar -c "$W/config-laptop.jsonc" -s "$S" &
            fi
            ;;
    esac
}

sw

# Reload on output changes to handle hotplugging
swaymsg -t subscribe -m '["output"]' 2>/dev/null | while read -r _; do
    sleep 0.8
    sw
done
