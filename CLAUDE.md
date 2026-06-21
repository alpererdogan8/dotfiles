# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Managing Dotfiles

**Install all packages:**
```bash
./install.sh
```

**Install specific packages:**
```bash
./install.sh hypr zsh waybar
```

**Preview changes without applying (dry run):**
```bash
./install.sh --dry-run
```

**Remove symlinks:**
```bash
./install.sh --remove
# or for specific packages:
./install.sh --remove hypr waybar
```

## Architecture

This repo uses **GNU Stow** to symlink config files into their target locations. Each top-level directory is a "package" with a fixed target defined in `install.sh`'s `TARGET` map.

**Stow convention:** files inside a package directory mirror the path relative to the target. For example:
- `zsh/.zshenv` → `~/.zshenv`
- `zsh/zsh/configs/.zshrc` → `~/zsh/configs/.zshrc` (because `ZDOTDIR=$HOME/zsh/configs`)
- `hypr/hyprland.lua` → `~/.config/hypr/hyprland.lua`

**Package → target mapping** (from `install.sh`):

| Package | Target |
|---------|--------|
| `alacritty`, `fastfetch`, `ghostty`, `hypr`, `nvim`, `rofi`, `swaync`, `swayosd`, `tmux`, `uwsm`, `waybar`, `yazi`, `snappy-switcher` | `~/.config/<name>` |
| `starship` | `~/.config` (starship.toml lands at `~/.config/starship.toml`) |
| `bash`, `git`, `zsh`, `vscode`, `local-bin` | `~HOME` |
| `ly` | `/etc/ly` (requires sudo — handled automatically) |

## Hyprland Config (Lua)

Hyprland config is written in **Lua** via `hyprland.lua`, which loads modules from `hypr/modules/`:

- `monitors.lua` — monitor layout, persistent workspace→monitor binding, native hotplug handling (`hl.monitor()`, `hl.workspace_rule({ monitor=, persistent= })`, `hl.on("monitor.added"/"monitor.removed")`), plus the global `MonitorProfiles` table (extend/external/laptop/mirror) called from the rofi switcher
- `env.lua` — environment variables (`hl.env()`)
- `autostart.lua` — startup apps (`hl.on("hyprland.start", ...)`)
- `config.lua` — general/decoration/animation/input settings (`hl.config()`)
- `rules.lua` — window and layer rules (`hl.window_rule()`, `hl.layer_rule()`)
- `keybinds.lua` — keybindings (`hl.bind()`)

The `hl` global is the Hyprland Lua API. All apps are launched via `uwsm app --` prefix for proper session management.

## Zsh Config Structure

`zsh/.zshenv` sets `ZDOTDIR=$HOME/zsh/configs`, so all zsh config files live in `~/zsh/configs/` (symlinked from `zsh/zsh/configs/`).

Load order: `.zshenv` → `.zshrc` → sourced files in this order:
1. `env.zsh` — PATH, EDITOR, GOPATH, fnm, starship env vars
2. `options.zsh` — setopt flags, FZF theme/opts
3. `aliases.zsh` — aliases and PATH prepend helper
4. `plugins.zsh` — Zinit plugin loading (zsh-vi-mode, fzf-tab, autosuggestions, syntax-highlighting, OMZ plugins)
5. `tools.zsh` — fnm, starship init, fzf keybinds, zoxide, tmuxifier
6. `tmux.zsh` — tmux auto-attach logic

Plugin manager: **Zinit** with deferred loading (`wait"0a"`, `wait"1"`, etc.) for fast startup. Profile with `ZSH_PROFILE=1 zsh`.

## Theme System

The active color palette is **Sunset Drive** — applied consistently across:
- Ghostty: `theme = Sunset Drive`
- Tmux: `source-file ~/.config/tmux/themes/sunset-drive.conf`
- Neovim: `colorscheme = "sunset-drive"` (custom color at `nvim/colors/sunset-drive.lua`)
- Yazi: `yazi/theme.toml` (root-level `theme.toml` is the Yazi theme)
- FZF: color opts in `options.zsh`
- Waybar/SwayNC: `style.css` files

Core palette: `bg=#0f0f1a`, accents `#00fcb9` (cyan), `#ff0063` (pink), `#00a4ff` (blue), `#ff57fd` (purple). Dim colors: `overlay=#5c6675` (borders, dark slate), `muted=#ffffff` (comments/dim text, white), `subtle=#8888a0` (secondary text). ANSI black=`#3e3e4b`, bright-black=`#ffffff`.

When changing the theme, update all of the above files.

## Key Design Decisions

- **No animations, blur, or shadows** — intentional performance choice (`config.lua`)
- **HDMI-A-1 is the primary monitor, eDP-1 the secondary** (both enabled in extend by default); lid switch keybinds toggle eDP-1
- **All autostart apps use `uwsm app --`** — required for UWSM session management; omitting it breaks session tracking
- **`vicinae`** serves dual roles: app launcher (`SUPER+R`) and clipboard history daemon (must be running as `vicinae server` at startup)
- **Workspaces 1–5** are bound to the primary monitor (HDMI-A-1), **6–10** to the secondary (eDP-1) via persistent `hl.workspace_rule` in `monitors.lua`. Monitor hotplug is handled natively in-process by `hl.on` events in `monitors.lua` (no external socat script) — on disconnect, an absent monitor's workspaces fall to the surviving one and return when it reconnects
- Turkish keyboard layout (`kb_layout = "tr"` in `config.lua`)
