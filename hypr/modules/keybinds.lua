-- modules/keybinds.lua

local mainMod = "SUPER"
-- local terminal = "uwsm app -- alacritty"
local terminal = "uwsm app -- ghostty"
local fileManager = "uwsm app -- nautilus"
local menu = "uwsm app -- vicinae toggle"

-------------------------
-- Window Management   --
-------------------------

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal .. " +new-window"))
--hl.bind(mainMod .. "+ Return", hl.dsp.exec_cmd(terminal)) --alacritty
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(
	mainMod .. " + ALT + W",
	hl.dsp.exec_cmd([[sh -c "hyprctl activewindow | grep 'pid:' | awk '{print $2}' | xargs kill -9"]])
)
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -R && swaync-client -rs && swaync-client -t -sw"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("$HOME/.local/bin/wallpaper_cycle.sh"))

-------------------------
-- Application Shortcuts--
-------------------------

-- Clipboard history
hl.bind("ALT + V", hl.dsp.exec_cmd("uwsm app -- vicinae vicinae://launch/clipboard/history"))

-- Screenshot → clipboard (hyprshot)
hl.bind(
	mainMod .. " + CTRL + S",
	hl.dsp.exec_cmd("uwsm app -- /home/polymath/.local/bin/hyprshot -m region --clipboard-only --silent")
)

-------------------------
-- Layout              --
-------------------------

hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + ALT + P", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.layout("swapnext"))

-------------------------
-- Focus               --
-------------------------

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-------------------------
-- Workspaces          --
-------------------------

for i = 1, 10 do
	local key = i % 10 -- 10 → key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll workspaces
hl.bind("ALT + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("ALT + left", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("ALT + CTRL + right", hl.dsp.focus({ workspace = "r+1" }))
hl.bind("ALT + CTRL + left", hl.dsp.focus({ workspace = "r-1" }))

-- Move window to adjacent workspace
hl.bind("ALT + SHIFT + right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind("ALT + SHIFT + left", hl.dsp.window.move({ workspace = "r-1" }))

-- Scratchpads
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + ALT + S", hl.dsp.workspace.toggle_special("extra"))
hl.bind(mainMod .. " + SHIFT + ALT + S", hl.dsp.window.move({ workspace = "special:extra" }))

-------------------------
-- Mouse               --
-------------------------

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-------------------------
-- Multimedia Keys     --
-------------------------

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

-------------------------
-- Lid Switch          --
-------------------------

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
