# Zsh Dotfiles — Installation Guide

This file contains all the tools, installation commands, and official links
required by the zsh configuration.

---

## 🔧 Automatically Installed (Zinit)

The following plugins are automatically downloaded by `plugins.zsh` and `tools.zsh`
via **zinit** on the first zsh session.
No manual installation is required.

| Plugin | Source |
|:---|:---|
| `zsh-vi-mode` | https://github.com/jeffreytse/zsh-vi-mode |
| `zsh-completions` | https://github.com/zsh-users/zsh-completions |
| `fzf-tab` | https://github.com/Aloxaf/fzf-tab |
| `zsh-autosuggestions` | https://github.com/zsh-users/zsh-autosuggestions |
| `zsh-syntax-highlighting` | https://github.com/zsh-users/zsh-syntax-highlighting |
| `zsh-abbr` | https://github.com/olets/zsh-abbr |
| `zsh-history-substring-search` | https://github.com/zsh-users/zsh-history-substring-search |
| `zsh-you-should-use` | https://github.com/MichaelAquilina/zsh-you-should-use |
| `tmuxifier` | https://github.com/jimeh/tmuxifier |
| OMZ: `git`, `sudo`, `command-not-found`, `docker` | https://github.com/ohmyzsh/ohmyzsh |

> Zinit itself is also automatically cloned by `plugins.zsh` if not present.
> Source: https://github.com/zdharma-continuum/zinit

---

## 📦 Manual Installation Required

### Fedora (dnf)

```bash
sudo dnf install -y \
    zsh \
    git \
    tmux \
    neovim \
    fzf \
    fd-find \
    ripgrep \
    git-delta \
    direnv \
    eza \
    bat
```

### Fedora — Packages Requiring Separate Sources

#### lsd (ls replacement)
```bash
sudo dnf copr enable atim/lsd
sudo dnf install -y lsd
```
🔗 https://github.com/lsd-rs/lsd

#### lazygit
```bash
sudo dnf copr enable atim/lazygit
sudo dnf install -y lazygit
```
🔗 https://github.com/jesseduffield/lazygit

#### lazydocker
```bash
go install github.com/jesseduffield/lazydocker@latest
```
🔗 https://github.com/jesseduffield/lazydocker

#### yazi (file manager — y() function)
```bash
sudo dnf copr enable atim/yazi
sudo dnf install -y yazi
```
🔗 https://github.com/sxyazi/yazi

#### zoxide (cd replacement)
```bash
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```
🔗 https://github.com/ajeetdsouza/zoxide

#### fnm (Node.js version manager)
```bash
curl -fsSL https://fnm.vercel.app/install | bash
```
🔗 https://github.com/Schniz/fnm

#### starship (prompt)
```bash
curl -sS https://starship.rs/install.sh | sh
```
🔗 https://starship.rs

#### thefuck
```bash
sudo dnf install -y pipx
pipx install thefuck
```
🔗 https://github.com/nvbn/thefuck


---

## 🚀 Quick Setup (In Order)

```bash
# 1. dnf packages
sudo dnf install -y zsh git tmux neovim fzf fd-find ripgrep git-delta direnv eza bat

# 2. COPR repos
sudo dnf copr enable atim/lsd && sudo dnf install -y lsd
sudo dnf copr enable atim/lazygit && sudo dnf install -y lazygit
sudo dnf copr enable atim/yazi && sudo dnf install -y yazi

# 3. Script-based installations
curl -sS https://starship.rs/install.sh | sh
curl -fsSL https://fnm.vercel.app/install | bash
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# 4. thefuck
sudo dnf install -y pipx && pipx install thefuck

# 5. Go tools (Go must be installed)
go install github.com/jesseduffield/lazydocker@latest

# 6. Set zsh as default shell
chsh -s $(which zsh)

# 7. Open a new session (zinit will auto-download plugins)
exec zsh
```

---

## 🗂 Configuration Files

| File | Description |
|:---|:---|
| `.zshenv` | ZDOTDIR and base env variables |
| `configs/.zshrc` | Main entry point, sources other files |
| `configs/env.zsh` | PATH and environment variables |
| `configs/options.zsh` | Zsh options and FZF settings |
| `configs/aliases.zsh` | Alias definitions |
| `configs/abbr.zsh` | Fish-style abbreviations (zsh-abbr) |
| `configs/completions.zsh` | Completion system settings |
| `configs/plugins.zsh` | Zinit plugin loading |
| `configs/tools.zsh` | CLI tool integrations (starship, fzf, zoxide, etc.) |
| `configs/tmux.zsh` | Automatic tmux session |
