-- modules/monitors.lua
-- Dinamik monitör yönetimi (Hyprland 0.55 Lua-native).
-- Birincil monitör → workspace 1-5, ikincil → workspace 6-10.
-- Tak-çıkar (hotplug) event'leri ve rofi profilleri aynı yardımcıları kullanır.

local PRIMARY = "HDMI-A-1"
local SECONDARY = "eDP-1"

local PRIMARY_MODE = "1920x1080@120"
local SECONDARY_MODE = "1366x768@60"

local PRIMARY_WS = { 1, 2, 3, 4, 5 }
local SECONDARY_WS = { 6, 7, 8, 9, 10 }

----------------------------------------------------------------------
-- Monitör specleri
----------------------------------------------------------------------

hl.monitor({ output = PRIMARY, mode = PRIMARY_MODE, position = "0x0", scale = "1", disabled = false })
hl.monitor({ output = SECONDARY, mode = SECONDARY_MODE, position = "auto-right", scale = "1", disabled = false })

----------------------------------------------------------------------
-- Kalıcı workspace → monitör bağlama (native).
-- Tek monitör kalınca Hyprland workspace'leri otomatik aktif monitöre düşürür;
-- monitör geri gelince kalıcı workspace'ler tekrar yerine döner.
----------------------------------------------------------------------

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

----------------------------------------------------------------------
-- Yardımcılar
----------------------------------------------------------------------

local function monitor_present(name)
	for _, m in ipairs(hl.get_monitors()) do
		if m.name == name then
			return true
		end
	end
	return false
end

-- Verilen workspace listesini hedef monitöre taşı.
local function move_ws(list, target)
	for _, ws in ipairs(list) do
		hl.dispatch(hl.dsp.workspace.move({ workspace = ws, monitor = target }))
	end
end

-- Layer-shell servislerini nazikçe yenile.
-- Output değişiminde waybar/swaync yüzeyleri ölebildiği için tetikleniyor.
local function refresh_bars()
	hl.exec_cmd("swaync-client -rs")
	hl.exec_cmd("pkill -SIGUSR2 waybar")
end

-- Bağlı monitörlere göre workspace'leri yeniden dağıt.
-- Bir monitör yoksa onun workspace'leri sağ kalan monitöre düşer.
local function reflow()
	local has_primary = monitor_present(PRIMARY)
	local has_secondary = monitor_present(SECONDARY)

	if not has_primary and not has_secondary then
		return
	end

	move_ws(PRIMARY_WS, has_primary and PRIMARY or SECONDARY)
	move_ws(SECONDARY_WS, has_secondary and SECONDARY or PRIMARY)
end

-- Topoloji oturduktan sonra reflow + bar yenileme.
-- Yeni etkinleştirilen output'un register olmasını beklemek için kısa gecikme
-- ("Monitor not found" yarışını önler).
local function schedule_reflow()
	hl.timer(function()
		reflow()
		refresh_bars()
	end, { timeout = 300, type = "oneshot" })
end

----------------------------------------------------------------------
-- Tak-çıkar (hotplug) event'leri
----------------------------------------------------------------------

hl.on("monitor.added", function()
	schedule_reflow()
end)

hl.on("monitor.removed", function()
	-- Sağ kalan monitörler zaten hazır; beklemeye gerek yok.
	reflow()
	refresh_bars()
end)

----------------------------------------------------------------------
-- Rofi profilleri (monitor_layout.sh → hyprctl eval ile çağrılır).
-- Global tablo: config ile aynı Lua state'inde yaşar, eval'den erişilir.
-- Yalnızca monitör speclerini ayarlar; bir monitör kapatılınca Hyprland onun
-- workspace'lerini otomatik taşır, schedule_reflow topoloji oturunca düzeltir.
----------------------------------------------------------------------

MonitorProfiles = {}

-- İki monitör yan yana (varsayılan düzen).
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
	schedule_reflow()
end

-- Sadece harici (birincil) monitör.
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
	schedule_reflow()
end

-- Sadece laptop (ikincil) ekranı.
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
	schedule_reflow()
end

-- Ayna: ikincil monitör birincili yansıtır.
function MonitorProfiles.mirror()
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
		position = "0x0",
		scale = "1",
		mirror = PRIMARY,
		disabled = false,
	})
	refresh_bars()
end
