-- modules/autostart.lua

hl.on("hyprland.start", function()
	-- System tray / applets
	hl.exec_cmd("uwsm app -- blueman-applet")
	hl.exec_cmd("uwsm app -- nm-applet --indicator")

	-- Bar & notifications
	hl.exec_cmd("uwsm app -- waybar")
	hl.exec_cmd("uwsm app -- swaync")

	-- Wallpaper
	--hl.exec_cmd("uwsm app -- $HOME/.local/bin/wallpaper_cycle.sh")

	-- Auth / security
	-- hl.exec_cmd("uwsm app -- /usr/lib/hyprpolkitagent")
	hl.exec_cmd("uwsm app -- /usr/lib/hyprpolkitagent/hyprpolkitagent")
	hl.exec_cmd("uwsm app -- /usr/lib/gsd-xsettings")
	hl.exec_cmd("uwsm app -- gnome-keyring-daemon --start --components=secrets")

	-- Utilities
	hl.exec_cmd("uwsm app -- awww-daemon")
	hl.exec_cmd("uwsm app -- hypridle")
	hl.exec_cmd("uwsm app -- swayosd-server")

	-- Monitor hotplug: move workspaces when HDMI connects/disconnects
	hl.exec_cmd("uwsm app -- $HOME/.config/waybar/scripts/monitor_hotplug.sh")

	-- Vicinae: clipboard daemon olarak başlat (clipboard history için şart)
	hl.exec_cmd("uwsm app -- vicinae")

	hl.exec_cmd("hyprctl setcursor Nordic-cursors 24")

	hl.exec_cmd("uwsm finalize")
end)
