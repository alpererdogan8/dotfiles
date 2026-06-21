local PRIMARY = "HDMI-A-1"
local SECONDARY = "eDP-1"

local PRIMARY_MODE = "1920x1080@120"
local SECONDARY_MODE = "1366x768@60"

local PRIMARY_WS = { 1, 2, 3, 4, 5 }
local SECONDARY_WS = { 6, 7, 8, 9, 10 }

hl.monitor({ output = PRIMARY, mode = PRIMARY_MODE, position = "0x0", scale = "1", disabled = false })
hl.monitor({ output = SECONDARY, mode = SECONDARY_MODE, position = "auto-right", scale = "1", disabled = false })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1", disabled = false })

for _, ws in ipairs(PRIMARY_WS) do
	hl.workspace_rule({
		workspace = tostring(ws),
		monitor = PRIMARY,
		persistent = true,
		default = (ws == PRIMARY_WS[1]),
	})
end

for _, ws in ipairs(SECONDARY_WS) do
	hl.workspace_rule({
		workspace = tostring(ws),
		monitor = SECONDARY,
		persistent = true,
		default = (ws == SECONDARY_WS[1]),
	})
end

local function refresh_bars()
	hl.exec_cmd("swaync-client -rs")
	hl.exec_cmd("pkill -SIGUSR2 waybar")
end

hl.on("monitor.added", function()
	hl.timer(function()
		refresh_bars()
	end, { timeout = 300, type = "oneshot" })
end)

hl.on("monitor.removed", function()
	refresh_bars()
end)

MonitorProfiles = {}

function MonitorProfiles.extend()
	hl.monitor({
		output = PRIMARY,
		mode = PRIMARY_MODE,
		position = "0x0",
		scale = "1",
		mirror = "none",
		disabled = false,
	})
	hl.monitor({
		output = SECONDARY,
		mode = SECONDARY_MODE,
		position = "auto-right",
		scale = "1",
		mirror = "none",
		disabled = false,
	})
	hl.timer(function()
		refresh_bars()
	end, { timeout = 300, type = "oneshot" })
end

function MonitorProfiles.external()
	hl.monitor({
		output = PRIMARY,
		mode = PRIMARY_MODE,
		position = "0x0",
		scale = "1",
		mirror = "none",
		disabled = false,
	})
	hl.monitor({ output = SECONDARY, disabled = true })
	hl.timer(function()
		refresh_bars()
	end, { timeout = 300, type = "oneshot" })
end

function MonitorProfiles.laptop()
	hl.monitor({
		output = SECONDARY,
		mode = SECONDARY_MODE,
		position = "0x0",
		scale = "1",
		mirror = "none",
		disabled = false,
	})
	hl.monitor({ output = PRIMARY, disabled = true })
	hl.timer(function()
		refresh_bars()
	end, { timeout = 300, type = "oneshot" })
end
