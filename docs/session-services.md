# Session services

Details that are easy to get wrong and silent when they are. The top-level
`README.md` covers the short version.

## Kanshi

`kanshi.service` in `systemd/user/` overrides the vendor unit in
`/usr/lib/systemd/user/`, because `~/.config/systemd/user` has the higher
load priority. Its output profiles are in `kanshi/config`, reached through the
Stow link at `~/.config/kanshi/config`.

Two behaviours are worth knowing before changing it:

- **Reload resets the layout.** A Sway config reload re-applies the output
  configuration, and this repository declares no `output` directives, so the
  monitors fall back to Sway's own default: 60Hz side by side. The stacked or
  extended layout is state Kanshi pushed, and Kanshi does not recover on its
  own: an immediate `kanshictl reload` after `swaymsg reload` loses the race,
  its commit lands while sway's reload transaction is still in flight, gets
  rejected and the screens stay at the default. The `$mod+Shift+c` binding runs
  `sway/scripts/reload-display`, which waits one second so sway has settled,
  then re-applies Kanshi. Only reloads through the binding re-apply Kanshi; a
  bare `swaymsg reload` from a terminal still drops the layout until the next
  Kanshi trigger.
- **`kanshictl switch` is a no-op** when the profile is already active, which is
  the normal case. `kanshictl reload` is the one that re-applies.
- **Never run bare `kanshi`.** It is a daemon, not a reload command. A second
  instance (for example `kanshi reload`) unlinks and rebinds
  `$XDG_RUNTIME_DIR/fr.emersion.kanshi.$WAYLAND_DISPLAY`, orphaning the
  systemd-managed daemon. Afterwards `kanshictl` either prints `Couldn't
  connect to kanshi` or silently talks to the stray instance, and reloading
  appears to do nothing. Check with `ss -xlp | grep kanshi`: exactly one
  listener should be listed, owned by the main PID of `kanshi.service`. The
  `$mod+Shift+c` helper detects this state and restarts the service, so the
  binding recovers on its own.

`exec` lines in a profile run without a shell, split on whitespace, with
quoting discarded. Use `exec swaymsg ...` directly and rely on `SWAYSOCK`
being inherited from the systemd user manager rather than discovering the
socket yourself.

## SwayOSD

Three failure modes, none of which report anything.

**The override files.** The volume, mute and media keys only show an OSD
because `sway/config.d/60-bindings-volume.conf`, `60-bindings-brightness.conf`
and `60-bindings-media.conf` override the bindings Sway ships in
`/usr/share/sway/config.d/`. Sway loads its own files first and later ones win,
so the overrides have to exist — with only some of them linked, the remaining
keys keep the stock binding and work with no OSD.

**Brightness needs the `video` group.** It writes to
`/sys/class/backlight/*/brightness`, which the packaged udev rule grants to
that group:

```bash
sudo usermod -a -G video $USER
```

Effective on the next login. Until then the keys exit 0 and change nothing,
because `swayosd-client` reports success whether or not the write landed.

**`swayosd-client` exits 0 on a bad argument**, so a typo in a binding is
invisible. Note that it wants `prev`, not playerctl's `previous`.

`swayosd-libinput-backend` is deliberately unused; it would watch the keyboard
directly for capslock and the scroll and number locks, which the bindings
already cover.

## playerctld

The media keys need an MPRIS proxy in front of the players on the bus, because
`playerctl` cannot otherwise decide which of several players a key press meant.

`playerctld` ships no unit on Fedora, only a D-Bus activation file, so systemd
never manages it properly. The unit in `systemd/user/` gives it a real one.

The ordering matters. Both the unit and D-Bus activation try to claim the same
bus name, and the loser exits with `could not acquire bus name`. D-Bus
activation wins if a media key was pressed before the unit was enabled, which
is the usual case. `Restart=on-failure` then loops on every start attempt, so
clear the stray process first:

```bash
pkill playerctld && systemctl --user start playerctld.service
```

## Checking a unit

```bash
./install.sh systemd
systemctl --user daemon-reload
systemctl --user status kanshi.service playerctld.service
```

Journal lines are the only place SwayOSD and Kanshi report errors, because both
exit 0 regardless:

```bash
journalctl --user -b | grep -iE 'swayosd|kanshi'
```
