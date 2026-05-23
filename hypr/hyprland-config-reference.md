# Hyprland Configuration Reference

> **Purpose:** Understand current setup in plain language — prepared with Sway migration in mind.

---

## Monitor Setup

| Output | Resolution / Refresh | Position | Scale | Notes |
|--------|---------------------|----------|-------|-------|
| `HDMI-A-1` | 1920×1080 @ 120 Hz | 0,0 (center) | 1 | Main desktop monitor |
| `eDP-1` | 1366×768 @ 60 Hz | auto (right of HDMI-A-1) | 1 | Built-in laptop display |

**Sway equivalent:** Uses the same `output` syntax — e.g. `output HDMI-A-1 mode 1920x1080@120Hz pos 0 0 scale 1`.

**Lid switch behavior:**
- Lid opens → re-enables the laptop screen (`eDP-1`)
- Lid closes → disables the laptop screen & locks via `hyprlock`

---

## Keybindings

### Modifier Key

`SUPER` (Windows/Command key) is the primary modifier, stored in `$mainMod`.

### General Shortcuts

| Shortcut | Action | Sway Equivalent |
|----------|--------|----------------|
| `SUPER + Enter` | Open terminal (Ghostty) | `bindsym $mod+Return exec ghostty` |
| `SUPER + W` | Close focused window | `bindsym $mod+W kill` |
| `SUPER + Alt + W` | Force-kill window by PID | Custom script |
| `SUPER + Shift + M` | Exit/end Hyprland session | `bindsym $mod+Shift+E exit` |
| `SUPER + E` | Open file manager (Nautilus) | `bindsym $mod+E exec nautilus` |
| `SUPER + V` | Toggle floating/tiling | `bindsym $mod+V floating toggle` |
| `SUPER + R` | Open app launcher (Vicinae) | `bindsym $mod+D exec wofi` |
| `SUPER + L` | Lock session (loginctl) | `bindsym $mod+L exec loginctl lock-session` |
| `SUPER + N` | Toggle notification center (Swaync) | Notification daemon |
| `SUPER + Shift + W` | Cycle wallpaper | Script |

### Window Management

| Shortcut | Action | Sway Equivalent |
|----------|--------|----------------|
| `SUPER + P` | Toggle pseudo-tiling | `bindsym $mod+Shift+Space floating toggle` |
| `SUPER + Alt + P` | Toggle fullscreen | `bindsym $mod+F fullscreen` |
| `SUPER + J` | Toggle split direction | `bindsym $mod+E layout toggle split` |
| `SUPER + Shift + J` | Swap with next window | `bindsym $mod+Shift+J swap` |
| `SUPER + arrows` | Move focus directionally | `bindsym $mod+{h,j,k,l} focus {left,down,up,right}` |

### Workspace Navigation

| Shortcut | Action |
|----------|--------|
| `SUPER + 1–0` | Switch to workspace 1–10 |
| `SUPER + Shift + 1–0` | Move window to workspace 1–10 |
| `Alt + Left/Right` | Previous/next workspace (e — empty) |
| `Alt + Ctrl + Left/Right` | Previous/next workspace (r — relative) |
| `Alt + Shift + Left/Right` | Move window to relative workspace |

### Special Workspaces (Scratchpads)

| Shortcut | Action |
|----------|--------|
| `SUPER + S` | Toggle scratchpad "magic" |
| `SUPER + Shift + S` | Move window to scratchpad "magic" |
| `SUPER + Alt + S` | Toggle scratchpad "extra" |
| `SUPER + Shift + Alt + S` | Move window to scratchpad "extra" |

### Multimedia Keys

| Key | Action |
|-----|--------|
| `XF86AudioRaiseVolume` | Raise volume (with OSD) |
| `XF86AudioLowerVolume` | Lower volume (with OSD) |
| `XF86AudioMute` | Toggle mute |
| `XF86MonBrightnessUp` | Brightness up (with OSD) |
| `XF86MonBrightnessDown` | Brightness down (with OSD) |

### Mouse Bindings

| Shortcut | Action |
|----------|--------|
| `SUPER + left-click` | Move window |
| `SUPER + right-click` | Resize window |

---

## Input Settings

### Keyboard
- **Layout:** Turkish (`tr`)
- **Follow mouse:** Enabled (focus follows cursor)

### Touchpad
- Natural scrolling: ON
- Tap-to-click: ON

### Mouse (epic-mouse-v1)
- Sensitivity: -0.5 (slower than default)

---

## Appearance & Window Behavior

### General
- **Gaps:** 1px inner, 2px outer
- **Border width:** 0px (borderless)
- **Layout:** Dwindle (master-stack with auto-splitting)
- **Tearing:** Disabled
- **VRR (Variable Refresh Rate):** Enabled

### Decorations
- **Rounding:** 10px (power 2 — slightly squared-off curves)
- **Opacity:** 100% (active & inactive)
- **Shadows:** Disabled
- **Blur:** Disabled

### Animations
- **All animations:** Disabled (performance preference)

### Misc
- Force default wallpaper: OFF (custom wallpaper via script)
- Hyprland logo: Visible on empty workspace
- Mouse/keyboard movement wakes display from DPMS sleep

---

## Window Rules (Per-Application)

### Vicinae (Launcher / Clipboard)
- Floating, centered, pinned across workspaces, no animation

### Loupe (Image Viewer)
- Floating, centered

### Celluloid (Video Player)
- Floating

### imv (Image Viewer)
- Floating

### Steam
- Floating with min-size 1×1 (allows it to be tiled when it wants)
- Tiled when title is exactly "Steam"
- Keeps focus when empty title

### Hyprpolkitagent (Auth Dialog)
- Floating, centered, 400×200, rounded with 2px blue border (`#3584e4`), dims background

### XWayland Video Bridge
- Hidden (`max_size 1 1`, `opacity 0.0`), no focus, no animation, no blur

### Global Suppress
- **Windowrule-1:** Suppress maximize events globally
- **Windowrule-2:** No focus for empty XWayland floating windows
- **Windowrule-3:** No blur globally (belt-and-suspenders)
- **Windowrule-4:** No borders/rounding for tiled windows on vertical tabbed/stacked workspaces
- **Windowrule-5:** No borders/rounding/shadows for fullscreen windows

---

## Layer Rules

| Namespace | Blur | Notes |
|-----------|------|-------|
| `waybar` | ON, ignore_alpha=0 | Top bar |
| `swaync-control-center` | ON, ignore_alpha=0.5, no_anim | Notification center panel |
| `swaync-notification-window` | ON, ignore_alpha=0.5, no_anim | Popup notifications |
| `swaync` | ON, ignore_alpha=0 | Base notification layer |
| `logout_dialog` | ON, ignore_alpha=0, fade anim | Logout UI |
| `wlogout` | ON, ignore_alpha=0 | Wlogout screen |

---

## Autostart

| Program | Purpose |
|---------|---------|
| `blueman-applet` | Bluetooth tray icon |
| `nm-applet --indicator` | Network manager tray |
| `waybar` | Status bar |
| `swaync` | Notification daemon |
| `wallpaper_cycle.sh` | Custom wallpaper rotation |
| `hyprpolkitagent` | Polkit authentication agent |
| `swww-daemon` | Wallpaper daemon |
| `hypridle` | Idle management daemon |
| `swayosd-server` | On-screen display (volume, brightness) |
| `gnome-keyring-daemon --start --components=secrets` | Secret/keyring storage |
| `uwsm finalize` | Finalize user service & window manager session |

---

## Environment Variables

### Wayland Enforcers
| Variable | Value | Purpose |
|----------|-------|---------|
| `GDK_BACKEND` | `wayland,x11` | GTK apps prefer Wayland |
| `QT_QPA_PLATFORM` | `wayland;xcb` | Qt apps prefer Wayland |
| `SDL_VIDEODRIVER` | `wayland` | SDL apps use Wayland |
| `CLUTTER_BACKEND` | `wayland` | Clutter toolkit uses Wayland |

### Browser Wayland Support
| Variable | Value | Purpose |
|----------|-------|---------|
| `MOZ_ENABLE_WAYLAND` | `1` | Firefox uses Wayland |
| `OZONE_PLATFORM` | `wayland` | Chromium-based browsers use Wayland |
| `ELECTRON_OZONE_PLATFORM_HINT` | `wayland` | Electron apps use Wayland |

### Desktop Environment
| Variable | Value | Purpose |
|----------|-------|---------|
| `XDG_SESSION_TYPE` | `wayland` | Session type |
| `XDG_CURRENT_DESKTOP` | `Hyprland` | Current DE identifier |
| `XDG_SESSION_DESKTOP` | `Hyprland` | Session desktop name |

### Cursor
- Hardware cursors: ON
- Hyprcursor: ON

### XWayland
- Force zero scaling: ON (prevents blurry X11 apps on HiDPI)

---

## Sway Migration Quick Reference

| Hyprland Concept | Sway Equivalent |
|-----------------|-----------------|
| `monitor = ...,1920x1080@120,...` | `output HDMI-A-1 mode 1920x1080@120Hz` |
| `bind = $mainMod, Return, exec, $terminal` | `bindsym $mod+Return exec ghostty` |
| `bind = $mainMod, 1, workspace, 1` | `bindsym $mod+1 workspace 1` |
| `bind = $mainMod SHIFT, 1, movetoworkspace, 1` | `bindsym $mod+Shift+1 move container to workspace 1` |
| `windowrulev3 = float, class:(vicinae)` | `for_window [class="vicinae"] floating enable` |
| `workspace = 1, monitor:HDMI-A-1` | `workspace 1 output HDMI-A-1` |
| `togglespecialworkspace, magic` | `scratchpad show` / `move scratchpad` |
| `input { kb_layout = tr }` | `input * xkb_layout tr` |
| `exec-once = uwsm app -- waybar` | `exec waybar` |
| `decoration { rounding = 10 }` | No direct equivalent (use `smart_borders` + gaps) |
| `misc { vrr = 1 }` | No direct equivalent |
