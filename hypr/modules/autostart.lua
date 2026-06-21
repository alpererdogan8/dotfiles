-- modules/autostart.lua

hl.on("hyprland.start", function()
	hl.exec_cmd("uwsm app -- kded6")

	-- System tray / applets
	hl.exec_cmd("uwsm app -- blueman-applet")
	hl.exec_cmd("uwsm app -- nm-applet --indicator")

	-- Bar & notifications
	hl.exec_cmd("uwsm app -- waybar")
	hl.exec_cmd("uwsm app -- swaync")

	-- Wallpaper
	--hl.exec_cmd("uwsm app -- $HOME/.local/bin/wallpaper_cycle.sh")

	-- Auth / security
	-- hl.exec_cmd("uwsm app -- /usr/lib/hyprpolkitagent/hyprpolkitagent") hyprland polkit
	hl.exec_cmd("/usr/lib/pam_kwallet_init")
	hl.exec_cmd("qdbus6 org.kde.kwalletd6 /modules/kwalletd6 org.kde.KWallet.open kdewallet 0 login")
	hl.exec_cmd("uwsm app -- /usr/lib/polkit-kde-authentication-agent-1")

	hl.exec_cmd("uwsm app -- gnome-keyring-daemon --start --components=secrets")

	-- hl.exec_cmd("uwsm app -- /usr/lib/gsd-xsettings")

	-- Utilities
	hl.exec_cmd("uwsm app -- awww-daemon")
	hl.exec_cmd("uwsm app -- hypridle")
	hl.exec_cmd("uwsm app -- swayosd-server")
	hl.exec_cmd("uwsm app -- snappy-switcher --daemon")
	-- Monitör tak-çıkar artık monitors.lua içinde native hl.on event'leriyle yönetiliyor.

	-- Vicinae: clipboard daemon olarak başlat (clipboard history için şart)
	hl.exec_cmd("uwsm app -- vicinae server")

	hl.exec_cmd("hyprctl setcursor Nordic-cursors 24")
	hl.exec_cmd("hyprmoncfgd")
	hl.exec_cmd("uwsm finalize")
end)
