-- Hyprland Lua Config
-- Converted from hyprland.conf
-- https://wiki.hypr.land/Configuring/Start/

------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@120", position = "0x0", scale = "1" })
hl.monitor({ output = "eDP-1", mode = "1366x768@60", position = "1920x0", scale = "1" })

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "uwsm app -- ghostty"
local fileManager = "uwsm app -- nautilus"
local menu = "uwsm app -- vicinae toggle"

-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
	hl.exec_cmd("uwsm app -- blueman-applet")
	hl.exec_cmd("uwsm app -- nm-applet --indicator")
	hl.exec_cmd("uwsm app -- waybar")
	hl.exec_cmd("uwsm app -- swaync")
	hl.exec_cmd("uwsm app -- /home/polymath/.local/bin/wallpaper_cycle.sh")
	hl.exec_cmd("uwsm app -- /usr/libexec/hyprpolkitagent")
	hl.exec_cmd("uwsm app -- awww-daemon")
	hl.exec_cmd("uwsm app -- hypridle")
	hl.exec_cmd("uwsm app -- swayosd-server")
	hl.exec_cmd("uwsm app -- gnome-keyring-daemon --start --components=secrets")
	hl.exec_cmd("uwsm finalize")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- Wayland global
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

-- Browsers
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("OZONE_PLATFORM", "wayland")

-- Session
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- See https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
	general = {
		gaps_in = 1,
		gaps_out = 2,
		border_size = 0,
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},

	decoration = {
		rounding = 10,
		rounding_power = 2,
		active_opacity = 1.0,
		inactive_opacity = 1.0,

		shadow = {
			enabled = false,
		},

		blur = {
			enabled = false,
			new_optimizations = true,
		},
	},

	animations = {
		enabled = false,
	},

	dwindle = {
		preserve_split = true,
	},

	misc = {
		disable_watchdog_warning = true,
		force_default_wallpaper = 0,
		disable_hyprland_logo = false,
		vrr = 1,
		mouse_move_enables_dpms = true,
		key_press_enables_dpms = true,
	},

	debug = {
		vfr = true,
	},

	render = {
		direct_scanout = false,
	},

	cursor = {
		no_hardware_cursors = false,
		enable_hyprcursor = true,
	},

	xwayland = {
		force_zero_scaling = true,
	},
})

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "tr",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		follow_mouse = 1,
		sensitivity = 0,

		touchpad = {
			natural_scroll = true,
			tap_to_click = true,
		},
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Smart gaps
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })

-- Monitor assignments
hl.workspace_rule({ workspace = "1", monitor = "HDMI-A-1", default = true })
hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "5", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "6", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "7", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "8", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "9", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "10", monitor = "eDP-1" })

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Vicinae (launcher overlay)
hl.window_rule({ name = "vicinae-float", match = { class = "vicinae" }, float = true })
hl.window_rule({ name = "vicinae-center", match = { class = "vicinae" }, center = true })
hl.window_rule({ name = "vicinae-pin", match = { class = "vicinae" }, pin = true })
hl.window_rule({ name = "vicinae-noanim", match = { class = "vicinae" }, no_anim = true })
hl.window_rule({ name = "vicinae-focus", match = { class = "vicinae" }, stay_focused = true })

-- xwaylandvideobridge: make invisible
hl.window_rule({
	name = "xwayland-video-bridge-fixes",
	match = { class = "xwaylandvideobridge" },

	no_initial_focus = true,
	no_focus = true,
	no_anim = true,
	no_blur = true,
	max_size = { 1, 1 },
	opacity = 0.0,
})

-- Suppress maximize events from all apps
hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

-- Fix XWayland floating drag issues
hl.window_rule({
	name = "fix-xwayland-drags",
	match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
	no_focus = true,
})

-- Disable blur globally
hl.window_rule({
	name = "no-blur-global",
	match = { class = "^.*$" },
	no_blur = true,
})

-- No border/rounding on tiled windows in smart-gap workspaces
hl.window_rule({
	name = "no-deco-tv1",
	match = { float = false, workspace = "w[tv1]" },
	border_size = 0,
	rounding = 0,
})

-- No deco on fullscreen windows
hl.window_rule({
	name = "no-deco-fullscreen",
	match = { fullscreen = true },
	rounding = 0,
	border_size = 0,
	no_shadow = true,
})

-- Loupe: float and center
hl.window_rule({ name = "loupe-float", match = { class = "^(loupe)$" }, float = true, center = true })

-- Celluloid: float
hl.window_rule({ name = "celluloid", match = { class = "^(celluloid)$" }, float = true })

-- imv: float
hl.window_rule({ name = "imv-float", match = { class = "^(imv)$" }, float = true })

-- Polkit agent: float, styled dialog
hl.window_rule({
	name = "polkit-dialog",
	match = { class = "^(hyprpolkitagent)$" },

	float = true,
	center = true,
	size = { 400, 200 },
	dim_around = true,
	stay_focused = true,
	rounding = 12,
	border_size = 2,
	border_color = "rgb(3584e4)",
})

-- Steam: float by default, tile main window
hl.window_rule({
	name = "steam-float",
	match = { class = "^(steam)$" },
	float = true,
	min_size = { 1, 1 },
})
hl.window_rule({
	name = "steam-tile",
	match = { class = "^(steam)$", title = "^(Steam)$" },
	tile = true,
})
hl.window_rule({
	name = "steam-focus",
	match = { class = "^(steam)$", title = "^()$" },
	stay_focused = true,
})

-- Layer rules
hl.layer_rule({
	name = "waybar-blur",
	match = { namespace = "waybar" },
	blur = true,
	ignore_alpha = 0,
})
hl.layer_rule({
	name = "swaync-cc-blur",
	match = { namespace = "swaync-control-center" },
	blur = true,
	ignore_alpha = 0.5,
	no_anim = true,
})
hl.layer_rule({
	name = "swaync-notif",
	match = { namespace = "swaync-notification-window" },
	blur = true,
	ignore_alpha = 0.5,
	no_anim = true,
})
hl.layer_rule({
	name = "swaync-blur",
	match = { namespace = "swaync" },
	blur = true,
	ignore_alpha = 0,
})
hl.layer_rule({
	name = "logout-blur",
	match = { namespace = "logout_dialog" },
	blur = true,
	ignore_alpha = 0,
	animation = "fade",
})
hl.layer_rule({
	name = "wlogout-blur",
	match = { namespace = "wlogout" },
	blur = true,
	ignore_alpha = 0,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Basic window management
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal .. " +new-window"))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(
	mainMod .. " + ALT + W",
	hl.dsp.exec_cmd([[sh -c "hyprctl activewindow | grep 'pid:' | awk '{print $2}' | xargs kill -9"]])
)
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exit()) -- exits Hyprland and returns to greetd
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -R && swaync-client -rs && swaync-client -t -sw"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("/home/polymath/.local/bin/wallpaper_cycle.sh"))

-- Application shortcuts
hl.bind("ALT + V", hl.dsp.exec_cmd("uwsm app -- vicinae vicinae://extensions/vicinae/clipboard/history"))
-- hl.bind(
-- 	mainMod .. " + CTRL + S",
-- 	hl.dsp.exec_cmd("uwsm app -- /home/polymath/.local/bin/hyprshot -m region --clipboard-only --silent")
-- )

hl.bind(
	mainMod .. " + CTRL + S",
	hl.dsp.exec_cmd("uwsm app -- sh -c 'spectacle -r -b -c -o ~/Pictures/screenshots/$(date +%Y%m%d_%H%M%S).png'")
)

-- Layout management
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + ALT + P", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.layout("swapnext"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with ALT + arrow keys
hl.bind("ALT + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("ALT + left", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("ALT + CTRL + right", hl.dsp.focus({ workspace = "r+1" }))
hl.bind("ALT + CTRL + left", hl.dsp.focus({ workspace = "r-1" }))

-- Move active window to adjacent workspace with ALT + SHIFT + arrow keys
hl.bind("ALT + SHIFT + right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind("ALT + SHIFT + left", hl.dsp.window.move({ workspace = "r-1" }))

-- Special workspaces (scratchpads)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + ALT + S", hl.dsp.workspace.toggle_special("extra"))
hl.bind(mainMod .. " + SHIFT + ALT + S", hl.dsp.window.move({ workspace = "special:extra" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia keys for volume control
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ 0 && swayosd-client --output-volume raise --max-volume 100"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ 0 && swayosd-client --output-volume lower --max-volume 100"),
	{ locked = true, repeating = true }
)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })

-- Laptop multimedia keys for LCD brightness
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("swayosd-client --brightness raise"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("swayosd-client --brightness lower"),
	{ locked = true, repeating = true }
)

-- Laptop lid switch handling
hl.bind(
	"switch:off:Lid Switch",
	hl.dsp.exec_cmd([[hyprctl keyword monitor "eDP-1, preferred, auto, 1"]]),
	{ locked = true }
)
hl.bind(
	"switch:on:Lid Switch",
	hl.dsp.exec_cmd([[sh -c 'hyprctl keyword monitor "eDP-1, disable" && hyprlock']]),
	{ locked = true }
)
