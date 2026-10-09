# Distribution package lists

The Fedora list lives in the top-level `README.md`, because Fedora is the
primary target. This file covers the two documented variants.

Every package here is called by something in `sway/config`, `waybar/` or a
script in `local-bin/` and `sway/scripts/`, so a missing one fails quietly:
the binding exists, the key does nothing.

## Arch Linux

```bash
sudo pacman -S stow git zsh fzf ripgrep fd eza bat zoxide \
  sway waybar swaylock rofi ghostty yazi tmux neovim starship btop \
  grim slurp wl-clipboard cliphist kanshi jq \
  uwsm playerctl gnome-keyring
```

SwayNC and a few others are not in the enabled repositories. With `yay`:

```bash
yay -S swaync
```

The Arch equivalents of the remaining Fedora packages are `kdeconnect`,
`awww` and `vicinae`.

## Debian / Ubuntu

```bash
sudo apt install stow git zsh fzf ripgrep fd-find bat zoxide \
  sway waybar swaylock rofi tmux neovim btop grim slurp \
  wl-clipboard kanshi jq \
  uwsm playerctl gnome-keyring
```

`eza`, `cliphist`, `ghostty`, `yazi`, `starship`, `swaync` and `wezterm` come
from the distribution repositories where available, and otherwise from their
upstream installers. SwayOSD is packaged from Debian trixie and Ubuntu Plucky
onwards.

## Fedora, beyond the main list

`swayosd` is the one package on Fedora that does not come from the
distribution repositories:

```bash
sudo dnf copr enable erikreider/swayosd
sudo dnf install swayosd
```

Its post-install requirements are in
[session-services.md](session-services.md).

## What `uwsm` is for

`sway/config` launches applications as `uwsm app -- <command>`, which places
each one in its own systemd scope. That is what makes the session's processes
visible to `systemctl --user` and stoppable individually on logout. Without
`uwsm` installed nothing is tracked, but the applications themselves still
open, so it is easy to miss.
