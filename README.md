# dotfiles

Wayland desktop configuration for Fedora (primary), with Arch and Debian notes. Managed with [GNU Stow](https://www.gnu.org/software/stow/): every top-level directory is a package that is symlinked into place.

<!-- ![screenshot](docs/screenshot.png) -->

| Component | Choice |
| --- | --- |
| Compositor / bar | Sway, Waybar |
| Display profiles | Kanshi (systemd user service) |
| Notifications / launcher | SwayNC, Rofi |
| Shell / prompt | Zsh (Zinit), Starship |
| Terminals | Ghostty, Kitty, Alacritty, WezTerm |
| Editor / multiplexer / files | Neovim (LazyVim), Tmux, Yazi |

## Install

```bash
git clone https://github.com/alpererdogan8/dotfiles.git ~/dotfiles
cd ~/dotfiles

sudo dnf install stow git zsh fzf ripgrep fd-find eza bat zoxide \
  sway waybar swaylock rofi yazi tmux neovim starship btop \
  grim slurp wl-clipboard cliphist kanshi jq \
  uwsm playerctl gnome-keyring SwayNotificationCenter kde-connect awww

./install.sh
```

`ghostty`, `wezterm` and `vicinae` are not in every repository. SwayOSD on Fedora comes from the COPR `erikreider/swayosd`, and Arch and Debian/Ubuntu package lists are in [docs/install.md](docs/install.md).

## Usage

```bash
./install.sh                 # link every package
./install.sh sway zsh        # link specific packages
./install.sh --relink sway   # pick up added or removed files
./install.sh --remove sway   # unlink
./install.sh --dry-run       # preview, change nothing
./install.sh --list          # link state of every package
./install.sh --is-linked     # silent check; exits 1 on problems (scripts, hooks)
```

Files are symlinked, never copied, so edits in the repository are live immediately. A `conflict` in `--list` means a real file sits where the link belongs: remove it and re-run the installer. The `ly` package targets `/etc/ly` and is installed with `sudo`.

## Adding an application

A new top-level directory is a package and deploys to `~/.config/<name>` by default. Only packages that mirror a path below `$HOME` are listed in `packages.conf`. Dot-directories are not packages.

```bash
mkdir -p fuzzel && cp fuzzel.conf fuzzel/
./install.sh fuzzel
```

## Session services

Daemons such as Kanshi run as systemd user units from `systemd/user/`, which override the vendor units.

```bash
./install.sh systemd
systemctl --user daemon-reload
systemctl --user restart kanshi.service
```

Brightness keys silently do nothing unless you are in the `video` group (re-login required):

```bash
sudo usermod -a -G video $USER
```

More notes (SwayOSD bindings, `playerctld`): [docs/session-services.md](docs/session-services.md).

## Secrets

Secrets are never tracked. Put them in `~/zsh/configs/local.zsh`:

```zsh
export EXAMPLE_API_KEY=your_key_here
```

## Themes

There is no shared theme source; palettes are set per application.

## Development

Conventions and the full validation checklist are in [CLAUDE.md](CLAUDE.md). Quick check:

```bash
./install.sh --dry-run && ./install.sh --is-linked
```