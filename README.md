# dotfiles

This repository contains the configuration files and scripts for a Fedora Wayland setup. It uses GNU Stow and targets Sway with Waybar, Kanshi, SwayNC, Zsh, and Neovim.

```text
Distribution         : Fedora
Window Manager       : Sway
Status Bar           : Waybar
Display Manager      : Kanshi + Sway
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

The core Fedora packages are:

```bash
sudo dnf install stow git zsh fzf ripgrep fd-find eza bat zoxide \
  sway waybar swaylock rofi yazi tmux neovim starship btop \
  grim slurp wl-clipboard cliphist kanshi jq
```

Install SwayNC, SwayOSD, power-profiles-daemon, GNOME Keyring, KDE Connect, Awww, UWSM, and the optional tools used by the session scripts separately when needed. The configuration intentionally guards optional tools where possible.

### Setup

```bash
git clone git@github.com:alpererdogan8/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Install all packages using Stow (creates symlinks)
./install.sh

# Install specific packages
./install.sh sway git ghostty

# Relink packages after adding or removing files
./install.sh --relink sway waybar

# List installation status
./install.sh --list

# Remove links
./install.sh --remove sway

# Preview without making changes
./install.sh --dry-run
```

The `ly` package targets `/etc/ly` and is installed with `sudo` by the installer. The runtime configurations are expected at their Stow targets, such as `~/.config/sway/config`; they do not require the repository to remain at `~/dotfiles`.

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
```

Waybar JSONC files should be checked with a Waybar reload in a graphical session. The repository does not currently include a CI test suite.
