# dotfiles

This repository contains the configuration files and scripts that I use on my Fedora Wayland setup. Managed with [GNU Stow](https://www.gnu.org/software/stow/) and themed with a custom **Sunset Drive** palette.

```text
Distribution         : Fedora
Window Manager       : Sway + Waybar
Shell                : Zsh
Terminal             : Ghostty / Kitty / Alacritty
Terminal Multiplexer : Tmux / herdr
Resource Monitor     : btop
Editor               : Neovim (LazyVim)
Notification Daemon  : SwayNotificationCenter
File Manager         : Yazi
App Launcher         : Rofi
Theme                : Sunset Drive
```

## Installation

### Prerequisites

You need to install the required packages before stowing the dotfiles. For Fedora:

```bash
sudo dnf install stow git zsh fzf ripgrep fd-find eza bat zoxide \
  sway waybar swaylock swaync rofi-wayland ghostty yazi tmux neovim \
  starship btop grim slurp wl-clipboard cliphist kanshi
```

### Setup
```bash
# Clone the repository
git clone git@github.com:alpererdogan8/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Install all packages using Stow (creates symlinks)
./install.sh

# Relink packages (useful if you added/removed files inside a package)
./install.sh --relink

# List installation status of all packages
./install.sh --list

# Remove (unlink) a specific package
./install.sh --remove sway

# Dry run (preview without making changes)
./install.sh --dry-run
```

## Preview

*(Ekran görüntülerini (screenshot) buraya ekleyebilirsin)*
