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

The `ly` package targets `/etc/ly` and is installed with `sudo`. All other packages use the current user's home directory.

## Architecture

The repository uses GNU Stow. A package is a top-level directory whose contents mirror paths below its target.

| Package | Target |
|---|---|
| `alacritty`, `fastfetch`, `ghostty`, `kanshi`, `kitty`, `nvim`, `rofi`, `sway`, `swaylock`, `swaync`, `swayosd`, `systemd`, `tmux`, `uwsm`, `waybar`, `yazi` | `~/.config/<package>` |
| `starship` | `~/.config` |
| `bash`, `git`, `local-bin`, `vscode`, `zsh` | `$HOME` |
| `ly` | `/etc/ly` |

Examples:

- `sway/config` → `~/.config/sway/config`
- `sway/config.d/90-bar.conf` → `~/.config/sway/config.d/90-bar.conf`
- `zsh/zsh/configs/.zshrc` → `~/zsh/configs/.zshrc`
- `local-bin/.local/bin/display-mode` → `~/.local/bin/display-mode`
- `systemd/user/kanshi.service` → `~/.config/systemd/user/kanshi.service`
- `starship/starship.toml` → `~/.config/starship.toml`

Runtime configuration paths should use installed Stow targets such as `~/.config/...`; they should not depend on the repository being located at `~/dotfiles`.

## Sway Session

The Sway entry point is `sway/config`. Monitor profiles are managed by Kanshi in `kanshi/config`.

Monitor profiles:

- `extend`: HDMI only; workspaces 1–10 are assigned to HDMI.
- `extended`: HDMI and laptop; workspaces 1–5 use HDMI and 6–10 use eDP.
- `mirror`: both outputs are enabled; the workspace assignment command uses HDMI for the shared workspace set.
- `laptop`: eDP only; workspaces 1–10 are assigned to eDP.

The output names are hardware-specific and currently assume `HDMI-A-1` and `eDP-1`. The display-mode switcher is `~/.local/bin/display-mode`. Workspace assignments are synchronized by `~/.local/bin/kanshi-workspace-assign` during manual profile changes and Waybar output events.

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

`local-bin/.local/bin/` contains session helpers such as display-mode selection, workspace movement, screenshots, wallpapers, health checks, and the webapp launcher. Scripts should use quoted arguments and safe shell-escaped generated commands.

## Validation

After changing dotfiles, run the available checks:

```bash
bash -n install.sh local-bin/.local/bin/* waybar/scripts/*.sh swaync/scripts/*.sh
zsh -n zsh/zsh/configs/*.zsh
sway -C -c sway/config
./install.sh --dry-run
```

Waybar JSONC files should be checked with the Waybar parser when a graphical Waybar restart is available. The repository does not currently include a CI test suite.
