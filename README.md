# dotfiles

This repository contains the configuration files and scripts for a Fedora, Arch, or Debian-based Wayland setup. It uses GNU Stow and targets Sway with Waybar, Kanshi, SwayNC, Zsh, and Neovim.

```text
Distribution         : Fedora
Window Manager       : Sway
Status Bar           : Waybar
Display Management   : Kanshi (systemd user service)
Shell                : Zsh (Zinit)
Terminals            : Ghostty / Kitty / Alacritty / WezTerm
Terminal Multiplexer : Tmux
Editor               : Neovim (LazyVim)
Notifications        : SwayNotificationCenter
File Manager         : Yazi
App Launcher         : Rofi
```

## Installation

### Prerequisites

The repository has a primary Fedora setup and documented Arch Linux and Debian/Ubuntu variants.

#### Fedora

```bash
sudo dnf install stow git zsh fzf ripgrep fd-find eza bat zoxide \
  sway waybar swaylock rofi yazi tmux neovim starship btop \
  grim slurp wl-clipboard cliphist kanshi jq
```

#### Arch Linux

```bash
sudo pacman -S stow git zsh fzf ripgrep fd eza bat zoxide \
  sway waybar swaylock rofi ghostty yazi tmux neovim starship btop \
  grim slurp wl-clipboard cliphist kanshi jq
```

If `yay` is available, install SwayNC and other packages unavailable in the enabled repositories through the AUR:

```bash
yay -S swaync
```

#### Debian / Ubuntu

```bash
sudo apt install stow git zsh fzf ripgrep fd-find bat zoxide \
  sway waybar swaylock rofi tmux neovim btop grim slurp \
  wl-clipboard kanshi jq
```

Install optional packages such as `eza`, `cliphist`, `ghostty`, `yazi`, `starship`, `swaync`, and `wezterm` from the distribution repositories, an AUR-equivalent source, or their official installers when they are not packaged for the release.

#### Optional session tools

Install SwayOSD, power-profiles-daemon, GNOME Keyring, KDE Connect, Awww, UWSM, and other tools used by session scripts separately when needed. The configuration guards optional tools where possible.

### Setup

```bash
git clone git@github.com:alpererdogan8/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Link every package using Stow (creates symlinks)
./install.sh

# Link specific packages
./install.sh sway git ghostty

# Relink packages after adding or removing files
./install.sh --relink sway waybar

# Remove links
./install.sh --remove sway

# Preview without making changes
./install.sh --dry-run

# Show the available options
./install.sh --help
```

The `ly` package targets `/etc/ly` and is installed with `sudo` by the installer. The runtime configurations are expected at their Stow targets, such as `~/.config/sway/config`; they do not require the repository to remain at `~/dotfiles`.

### Checking link state

`./install.sh` never copies files. Each package is a Stow package whose contents are symlinked into place, so a change in the repository is live immediately. The risk is the opposite one: a file added to the repository that was never linked.

```bash
# Table of every package, its target and its link state
./install.sh --list

# Check only: no output when everything is linked
./install.sh --is-linked && echo "all linked"
```

`--is-linked` is the form to use in scripts and commit hooks. It prints nothing on success and exits 0. On failure it writes what is wrong to stderr and exits 1, or exits 2 if the checker itself cannot run. A package counts as linked only when every one of its tracked files is in place; a single unlinked file is reported.

The same check is available directly as `stow-status.sh`, which takes `--brief` for the table without per-file details and `--quiet` for the silent form.

## Session Services

Kanshi is managed by systemd rather than by `sway/config`, and its unit lives in this repository at `systemd/user/kanshi.service`. It overrides the unit shipped by the package, because `~/.config/systemd/user` has a higher systemd load priority than `/usr/lib/systemd/user`.

```bash
./install.sh systemd
systemctl --user daemon-reload
systemctl --user restart kanshi.service
systemctl --user status kanshi.service
```

Output profiles stay in `kanshi/config`, reached through the Stow link at `~/.config/kanshi/config`.

## Local Secrets

Secrets are not tracked by Git. Create `~/zsh/configs/local.zsh` for secrets loaded by the Zsh configuration:

```zsh
export EXAMPLE_API_KEY=your_key_here
```

The loader also accepts the legacy `~/.config/zsh/local.zsh` location. Local files should remain untracked.

## Themes

There is no single cross-application theme source in this repository. Terminal, tmux, Ghostty, Neovim, Yazi, Starship, and FZF currently use independent palettes. Theme changes should be made per application instead of assuming the old Sunset Drive documentation applies everywhere.

## Validation

After changing dotfiles, run:

```bash
bash -n install.sh local-bin/.local/bin/* waybar/scripts/*.sh swaync/scripts/*.sh
zsh -n zsh/zsh/configs/*.zsh
sway -C -c sway/config
./install.sh --dry-run
./install.sh --is-linked
```

Waybar JSONC files should be checked with a Waybar reload in a graphical session. The repository does not currently include a CI test suite.
