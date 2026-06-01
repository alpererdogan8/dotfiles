-- modules/config.lua

hl.config({
	general = {
		gaps_in = 2,
		gaps_out = 2,
		border_size = 0,
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},

	decoration = {
		rounding = 0,
		rounding_power = 0,
		active_opacity = 1,
		inactive_opacity = 1,

		shadow = { enabled = false },

		blur = {
			enabled = false,
			new_optimizations = true,
		},
	},

	animations = {
		enabled = false,
	},

	dwindle = { preserve_split = true },

	misc = {
		disable_watchdog_warning = true,
		force_default_wallpaper = 0,
		disable_hyprland_logo = false,
		vrr = 1,
		mouse_move_enables_dpms = true,
		key_press_enables_dpms = true,
	},

	debug = { vfr = true },
	render = { direct_scanout = false },

	cursor = {
		no_hardware_cursors = false,
		enable_hyprcursor = true,
	},

	xwayland = { force_zero_scaling = true },
})

-- Input
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

-- Gestures
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- Devices
hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})
