# Dotfiles Guide

This repository contains the configuration files and scripts for a Fedora Wayland setup. The primary compositor is Sway; Hyprland is not part of this repository.

## Managing Dotfiles

Install all packages:

```bash
./install.sh
```

Install specific packages:

```bash
./install.sh sway waybar zsh
```

Preview changes without applying them:

```bash
./install.sh --dry-run
```

Remove links:

```bash
./install.sh --remove
./install.sh --remove sway waybar
```

Relink a package after adding or removing files:

```bash
./install.sh --relink sway waybar
```

List installation status:

```bash
./install.sh --list
```

Check whether every package is linked, without any output. Exits 0 when all packages are linked, 1 when any package has a broken, missing, conflicting or absolute link, and 2 when the link checker itself cannot run. This is the form to use in scripts and commit hooks:

```bash
./install.sh --is-linked || echo "run ./install.sh"
```

The `ly` package targets `/etc/ly` and is installed with `sudo`. All other packages use the current user's home directory.

## Architecture

The repository uses GNU Stow. A package is a top-level directory whose contents mirror paths below its target.

**The set of packages is discovered, not registered.** Any top-level directory is a package, and the convention is that it deploys to `~/.config/<name>`. Creating a directory in the repository is the whole of the work — `./install.sh <name>`, `./install.sh` and `./install.sh --list` all pick it up with no edit to any script. A registry would have been the alternative, and it fails in a specific way: a new package that nobody remembered to add is not an error, it is simply never installed and never reported as missing.

`packages.conf` at the repository root holds the exceptions and the shared helpers, and is sourced by both `install.sh` and `stow-status.sh` so the installer and the checker cannot disagree about the set. Directories whose name starts with a dot are not packages — stow skips those unless run with `--dotfiles`, so a target for one could never be honoured.

The overrides, all of which are packages whose contents mirror a path that is not `~/.config/<name>`:

| Package | Target | Why |
|---|---|---|
| `starship` | `~/.config` | `starship.toml` is read from `~/.config/starship.toml` |
| `bash`, `git`, `local-bin`, `vscode`, `zsh` | `$HOME` | they mirror paths below `$HOME` itself (`.bashrc`, `.gitconfig`, `.local/bin/*`) |
| `ly` | `/etc/ly` | system package, installed with sudo |

Examples:

- `sway/config` → `~/.config/sway/config`
- `sway/config.d/90-bar.conf` → `~/.config/sway/config.d/90-bar.conf`
- `zsh/zsh/configs/.zshrc` → `~/zsh/configs/.zshrc`
- `local-bin/.local/bin/display-mode` → `~/.local/bin/display-mode`
- `systemd/user/kanshi.service` → `~/.config/systemd/user/kanshi.service`
- `starship/starship.toml` → `~/.config/starship.toml`
- `wezterm/wezterm.lua` → `~/.config/wezterm/wezterm.lua` (no override needed)

Runtime configuration paths should use installed Stow targets such as `~/.config/...`; they should not depend on the repository being located at `~/dotfiles`.

## Sway Session

The Sway entry point is `sway/config`. Monitor profiles are managed by Kanshi in `kanshi/config`.

Monitor profiles:

- `extend`: HDMI only; workspaces 1–10 are assigned to HDMI.
- `extended`: HDMI and laptop; workspaces 1–5 use HDMI and 6–10 use eDP.
- `mirror`: both outputs are enabled; the workspace assignment command uses HDMI for the shared workspace set.
- `laptop`: eDP only; workspaces 1–10 are assigned to eDP.

The output names are hardware-specific and currently assume `HDMI-A-1` and `eDP-1`. The display-mode switcher is `~/.local/bin/display-mode`. Workspace assignments are synchronized by `~/.config/sway/scripts/kanshi-workspace-assign` during manual profile changes and Waybar output events.

Waybar selects its configuration from the active Kanshi profile and active outputs:

- `config-extend.jsonc` for HDMI-only mode
- `config-extended.jsonc` for extended and mirror layouts
- `config-laptop.jsonc` for laptop-only mode

The custom battery module is defined for each bar that uses it. The battery script derives watts from charge-change samples and must always emit valid JSON.

Sway starts several session services from `sway/config`, including KDE Connect, SwayOSD, Awww, clipboard history, and the keyring daemon. Applications that need session tracking use `uwsm app --`; short-lived commands may run directly.

Kanshi is not started from `sway/config`; it runs as a systemd user service. The `systemd` package owns `systemd/user/kanshi.service`, which overrides the vendor unit in `/usr/lib/systemd/user/` because `~/.config/systemd/user` has higher load priority. Stowing the file is enough — systemd resolves the unit by name and picks the highest-priority file:

```bash
./install.sh systemd
systemctl --user daemon-reload
systemctl --user restart kanshi.service
```

`graphical-session.target.wants/kanshi.service` is what makes the unit start with the session. Its target path is cosmetic: the vendor and dotfiles units share a name, so the link works either way. The dotfiles path is used so `systemctl --user disable` does not remove the Stow link. Do not run `systemctl --user disable kanshi.service` during normal operation — it also deletes the Stow-managed symlink and hands control back to the vendor unit. If that happens, re-run `./install.sh systemd` and recreate the enablement symlink:

```bash
ln -sfn "$HOME/dotfiles/systemd/user/kanshi.service" \
  ~/.config/systemd/user/graphical-session.target.wants/kanshi.service
systemctl --user daemon-reload
```

Only one kanshi process may run. A leftover process spawned by an older `sway/config` `exec_always` line stays in the `wayland-wm@sway.service` cgroup until sway exits, so after removing that line, check `pgrep -a kanshi` and kill the stray process.

Keep the config path as the Stow target `~/.config/kanshi/config`; do not hardcode the repository location.

## Low Battery Notification

`systemd/user/battery-notify.service` and `systemd/user/battery-notify.timer` raise a notification below 30% and a second, more insistent one below 20%. Enable them with `./install.sh systemd` and `systemctl --user enable --now battery-notify.timer`.

The timer polls once a minute and the whole decision lives in one `ExecStart` line, so there is no monitoring script to install or keep in sync. Every behaviour is an `Environment=` knob at the top of the unit — thresholds, sound file, repeat counts, icons, state file name — and a drop-in overrides any of them without touching the repo:

```bash
mkdir -p ~/.config/systemd/user/battery-notify.service.d
printf '[Service]\nEnvironment=WARN=25\nEnvironment=BEEPS_CRIT=5\n' \
  > ~/.config/systemd/user/battery-notify.service.d/override.conf
systemctl --user daemon-reload
```

Why it is not built out of SwayNC, notify-send and Waybar, since that is the obvious first thing to try:

- **SwayNC has no sound engine.** There is no `sounds` key in its config schema and no audio code in its daemon; the `"sounds": {"notification": …, "critical": …}` block that appears in guides does not exist. Its only audio hook is the `scripts` config block, which runs a shell command against an incoming notification.
- **notify-send can only send.** `-u critical` changes urgency, which SwayNC spends on `timeout-critical` and the critical CSS class. The `sound-file` hint from libnotify 0.8.8 is accepted and then ignored.
- **Waybar cannot raise notifications.** `battery.states` only recolours the bar, and `on-click` / `on-scroll-*` are manual.

None of the three can watch the battery, and none of them can play a sound, so the threshold decision needs a fourth thing. A systemd timer is the smallest one available. Audio is played with `pw-play` in the unit rather than through a SwayNC `scripts` entry, which keeps `swaync/config.json` untouched and stops a failed sound from taking the notification down with it.

`waybar/config*.jsonc` sets `battery.states.critical` to 30 so the bar turns red at the same moment the first notification appears. That value and `Environment=WARN` are the same threshold expressed twice; change both together.

Notifications fire once per threshold per discharge, tracked in `$XDG_RUNTIME_DIR/battery-notify.stage` (`0` nothing announced, `1` warned, `2` critical). The stage is cleared only once the charge climbs back above `RESET`, which is 5 points above `WARN`. Merely being plugged in is deliberately not a reset: otherwise a battery warned about at 28% that gets plugged in for a moment and unplugged at 29% would warn again. A full charge is the only way to re-arm. The stage advances only if `notify-send` succeeded, so a session that starts before SwayNC retries on the next poll instead of swallowing the warning.

Do not use `dialog-error.oga` to distinguish the levels: in `sound-theme-freedesktop` it is a symlink to `dialog-warning.oga`, so the two are the same audio. The unit uses one short 0.14 s `bell.oga` repeated instead, because the alternative — `alarm-clock-elapsed.oga` — is 6.1 s of beeping.

For the same reason the icons are `breeze-dark` rather than `AdwaitaLegacy`: the legacy theme draws a shaded 3D cell that looks out of place in a notification, and plain `breeze` draws dark-on-dark and disappears on the dark panel.

Sound reaching the speakers is a separate problem from the PipeWire volume. If `pw-play` is silent while `wpctl get-volume` shows a healthy level, the ALSA hardware mixer is the culprit: `amixer -c 0 sget Headphone` shows `0 [0%] [off]`, and a PipeWire volume of 0.9 changes nothing while the channel is off at the hardware level. Check the jack too — an empty 3.5 mm jack also sends the analog sink nowhere.

## Zsh Configuration

`zsh/.zshenv` sets `ZDOTDIR=$HOME/zsh/configs`. The active `.zshrc` sources files in this order:

1. `env.zsh`
2. `options.zsh`
3. `aliases.zsh`
4. `completions.zsh`
5. `plugins.zsh`
6. `tools.zsh`
7. `git.zsh`
8. `herdr.zsh`

`tmux.zsh` is present but is not currently sourced. Herdr is optional and runs only for an interactive terminal when it is installed and `HERDR_ENV` is unset.

Zinit installs missing plugins on the first shell start. Optional tools such as fnm, Starship, direnv, Yazi, and Herdr are guarded where possible. `ZSH_PROFILE=1 zsh` enables zprof output.

Local secrets can be stored in `~/zsh/configs/local.zsh`. The loader also accepts the legacy `~/.config/zsh/local.zsh` location.

## Neovim Configuration

Neovim uses LazyVim with local overrides in `nvim/lua/`. Lazy.nvim bootstraps the `stable` branch on first use. The current theme configuration is not a single shared palette: terminal, tmux, Ghostty, Neovim, Yazi, Starship, and FZF contain independent theme choices.

`vim.g.lazyvim_colorscheme` and the local theme plugin should agree when changing the Neovim theme.

## Themes

There is currently no single cross-application theme source. Changing a theme requires reviewing the relevant files under `alacritty/`, `kitty/`, `ghostty/`, `tmux/`, `wezterm/`, `nvim/`, `yazi/`, `starship/`, and `zsh/zsh/configs/options.zsh`.

## Local Scripts

`local-bin/.local/bin/` contains session helpers that are not sway-specific: display-mode selection, clipboard history, the rofi launcher, wallpapers, volume control, health checks, and the webapp launcher. Workspace and output scripts live in `sway/scripts/` instead, because they talk to sway over IPC and are only ever called from sway bindings, Waybar's output handler, or `display-mode`. Scripts should use quoted arguments and safe shell-escaped generated commands.

`stow-status.sh` reports the link state of every package. It is the single implementation behind both `./install.sh --list` and `./install.sh --is-linked`; `install.sh` only forwards to it and propagates its exit status, so there is one definition of "linked" rather than two that can disagree. It sources `packages.conf` — the same file `install.sh` sources, and never `install.sh` itself, which would run the installer — and builds the same map from the same discovery, so the two cannot drift. It locates the repository from the path `install.sh` passes it, or by resolving its own symlink when run directly. `--brief` prints the table and summary only, `--quiet` prints nothing and reports through the exit status. It checks every file in a package rather than only the first, so a single unlinked file is no longer hidden. Because Stow sometimes links a whole directory, a file reached through a linked parent directory counts as linked even though it is a real file. The script exits non-zero when any package is not fully linked.

A `conflict` is a real file where the link belongs, not a broken symlink. Stow refuses to touch such a package at all ("existing target is not owned by stow"), so the fix is to remove the file and re-run the installer rather than to pass `--relink`.

Two classes of file are excluded from the link count. The first is paths ignored by `.gitignore` (local artifacts such as `node_modules`, `__pycache__`, `.zcompdump`, `zsh_history`). The second is files GNU Stow itself would not deploy. That second class follows stow's real algorithm rather than a name list, because the two disagree in ways that change the answer:

- A pattern containing `/` is tested as `(^|/)(pattern)(/|$)` against `/`+the path relative to the package root. A pattern without `/` is tested as `^(pattern)$` against the basename only. So `^/README.*` skips `README.md` at the package root but **not** `sub/README.md`, while `.gitignore` is skipped at any depth. `LICENCE` is not in stow's list, only `LICENSE`.
- The test runs on directories as well as files, and an ignored directory is never descended into, so a file is ignored when it or any ancestor inside the package matches.
- Patterns are Perl regular expressions, not globs, and a comment needs whitespace in front of its `#` — which is why `\.#.+` (emacs lock files) survives as a pattern instead of being cut short at the `#`.
- An ignore file *replaces* the built-in list rather than extending it. Stow reads it from the package directory and then from `~/.stow-global-ignore`, never from the repository root; a `.stow-local-ignore` at the repo root looks effective and does nothing, so its presence is reported as a warning.

Note that a folded directory link defeats the ignore list entirely: once Stow links `themes/` as one directory, everything inside it is deployed whatever the list says.

The report ends with a package inventory. Because the set is discovered, no directory can hide from the table above; what the inventory states instead is the two ways the inventory itself can be wrong. An `OVERRIDE_TARGET` entry naming a directory that does not exist is the one that bites: discovery walks directories, so a typo there produces no package at all and the override is silently inert, leaving the package to deploy to the convention target instead of the intended one. The inventory lists those, along with the dot-directories, so the package count can be read correctly. Reporting only — neither affects the exit status.

An absolute symlink into the repository is reported as `absolute`, not `linked`. Stow only ever creates relative links and compares the raw link text, so a hand-made absolute link makes it abort the entire package with "existing target is not owned by stow". Resolving the link would hide this, which is why the raw target is checked. Fix it by removing the link and re-running the installer; `--relink` does not work here because the unstaging step fails the same way:

```bash
rm ~/.config/rofi/launcher.rasi
./install.sh rofi
```

## Validation

After changing dotfiles, run the available checks:

```bash
bash -n install.sh packages.conf local-bin/.local/bin/* sway/scripts/* waybar/scripts/*.sh swaync/scripts/*.sh
zsh -n zsh/zsh/configs/*.zsh
sway -C -c sway/config
systemd-analyze verify systemd/user/battery-notify.service systemd/user/battery-notify.timer
./install.sh --dry-run
./install.sh --is-linked
```

`stow-status.sh` also carries a behavioural contract that a syntax check cannot
catch: its ignore rules have to agree with what GNU Stow actually does, and the
two drift silently. The way to check that is differential — build a fixture
package full of awkward names, ask `stow -nv --no-folding` which files it would
link, and confirm the script agrees on every one of them:

```bash
T=$(mktemp -d); mkdir -p "$T/repo/pkg/sub/deep" "$T/target" "$T/home"
cd "$T/repo/pkg"
touch README.md README LICENSE LICENCE COPYING .gitignore .gitconfig \
      config.conf RCS CVS 'file,v' '.notes~' '.#lock' '#auto#'
touch sub/README.md sub/COPYING sub/.gitignore sub/deep/README.md
cd "$T/repo"

HOME="$T/home" stow -nv --no-folding -d . -t "$T/target" pkg \
  | grep '^LINK:' | sed 's/^LINK: //; s/ =>.*//' | sort
```

Use `--no-folding`: with the default folder folding Stow links a whole
directory and never looks inside, which hides every ignore rule that applies to
its contents. Nine scenarios are worth keeping green — defaults, a
package-local list, a global list, comment and escape handling, regex patterns,
a segment pattern that collides with a directory name, a path pattern pointing
at a nested directory, and blank input lines.

Waybar JSONC files should be checked with the Waybar parser when a graphical Waybar restart is available. The repository does not currently include a CI test suite.
