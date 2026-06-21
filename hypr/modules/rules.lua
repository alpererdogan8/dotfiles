-- modules/rules.lua

--------------------
-- Workspace Rules --
--------------------
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })

hl.workspace_rule({ workspace = "1", monitor = "HDMI-A-1", default = true, persistent = true })
hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1", persistent = true })
hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-1", persistent = true })
hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-1", persistent = true })
hl.workspace_rule({ workspace = "5", monitor = "HDMI-A-1", persistent = true })
hl.workspace_rule({ workspace = "6", monitor = "eDP-1", default = true, persistent = true })
hl.workspace_rule({ workspace = "7", monitor = "eDP-1", persistent = true })
hl.workspace_rule({ workspace = "8", monitor = "eDP-1", persistent = true })
hl.workspace_rule({ workspace = "9", monitor = "eDP-1", persistent = true })
hl.workspace_rule({ workspace = "10", monitor = "eDP-1", persistent = true })

-------------------
-- Window Rules  --
-------------------

-- Vicinae (launcher overlay)
hl.window_rule({ name = "vicinae-float", match = { class = "vicinae" }, float = true })
hl.window_rule({ name = "vicinae-center", match = { class = "vicinae" }, center = true })
hl.window_rule({ name = "vicinae-pin", match = { class = "vicinae" }, pin = true })
hl.window_rule({ name = "vicinae-noanim", match = { class = "vicinae" }, no_anim = true })
hl.window_rule({ name = "vicinae-focus", match = { class = "vicinae" }, stay_focused = true })

-- hyprmoncfg-pin

hl.window_rule({ name = "hyprmoncfg-float", match = { title = "hyprmoncfg" }, float = true })
hl.window_rule({ name = "hyprmoncfg-size", match = { title = "hyprmoncfg" }, size = { 1360, 740 } })
hl.window_rule({ name = "hyprmoncfg-activate", match = { class = "hyprmoncfg" }, focus_on_activate = true })
hl.window_rule({ name = "hyprmoncfg-center", match = { title = "hyprmoncfg" }, center = true })
hl.window_rule({ name = "hyprmoncfg-pin", match = { title = "hyprmoncfg" }, pin = true })
hl.window_rule({ name = "hyprmoncfg-noanim", match = { title = "hyprmoncfg" }, no_anim = true })
hl.window_rule({ name = "hyprmoncfg-focus", match = { title = "hyprmoncfg" }, stay_focused = true })

-- XWayland video bridge: completely invisible
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

-- Suppress maximize events globally
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
-- hl.window_rule({
-- 	name = "no-blur-global",
-- 	match = { class = "^.*$" },
-- 	no_blur = true,
-- })

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

-- Loupe: float + center
hl.window_rule({ name = "loupe-float", match = { class = "^(loupe)$" }, float = true, center = true })

-- Celluloid: float
hl.window_rule({ name = "celluloid", match = { class = "^(celluloid)$" }, float = true })

-- imv: float
hl.window_rule({ name = "imv-float", match = { class = "^(imv)$" }, float = true })

-- Polkit agent dialog
hl.window_rule({
	name = "polkit-dialog",
	match = { class = "^(hyprpolkitagent)$" },
	workspace = "current",
	float = true,
	center = true,
	size = { 400, 200 },
	dim_around = true,
	stay_focused = true,
	rounding = 12,
	border_size = 2,
	border_color = "rgb(3584e4)",
})
--Ghostty in Btop
hl.window_rule({
	match = {
		class = "^(com.mitchellh.ghostty)$",
		title = "^(btop-float)$",
	},
	float = true,
	center = true,
	size = { 1000, 650 },
})
--Ghostty in Bluetui
hl.window_rule({
	match = {
		class = "^(com.mitchellh.ghostty)$",
		title = "^(bluetui-float)$",
	},
	float = true,
	center = true,
	size = { 1000, 650 },
})

-- Steam: float by default, tile main window
hl.window_rule({
	name = "steam-float",
	match = { class = "^(steam)$" },
	float = true,
	min_size = { 1, 1 },
})
hl.window_rule({ name = "steam-tile", match = { class = "^(steam)$", title = "^(Steam)$" }, tile = true })
hl.window_rule({ name = "steam-focus", match = { class = "^(steam)$", title = "^()$" }, stay_focused = true })

-------------------
-- Layer Rules   --
-------------------

hl.window_rule({
	match = { class = "waybar" },
	no_shadow = true,
	no_blur = true,
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
