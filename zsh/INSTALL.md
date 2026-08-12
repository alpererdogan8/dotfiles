# Zsh Dotfiles — Installation Guide

Bu dosya, zsh yapılandırmasının ihtiyaç duyduğu tüm araçları,
kurulum komutlarını ve resmi bağlantılarını içerir.

---

## 🔧 Otomatik Yüklenenler (Zinit)

Aşağıdaki eklentiler `plugins.zsh` ve `tools.zsh` tarafından
ilk zsh oturumunda **zinit** aracılığıyla otomatik indirilir.
Manuel kurulum gerekmez.

| Eklenti | Kaynak |
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

> Zinit kendisi de yoksa `plugins.zsh` tarafından otomatik klonlanır.
> Kaynak: https://github.com/zdharma-continuum/zinit

---

## 📦 Manuel Kurulum Gerektirenler

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

### Fedora — Ayrı Kaynak Gerektiren Paketler

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

#### yazi (file manager — y() fonksiyonu)
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

## 🚀 Hızlı Kurulum (Sırasıyla)

```bash
# 1. dnf paketleri
sudo dnf install -y zsh git tmux neovim fzf fd-find ripgrep git-delta direnv eza bat

# 2. COPR repoları
sudo dnf copr enable atim/lsd && sudo dnf install -y lsd
sudo dnf copr enable atim/lazygit && sudo dnf install -y lazygit
sudo dnf copr enable atim/yazi && sudo dnf install -y yazi

# 3. Script ile kurulanlar
curl -sS https://starship.rs/install.sh | sh
curl -fsSL https://fnm.vercel.app/install | bash
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# 4. thefuck
sudo dnf install -y pipx && pipx install thefuck

# 5. Go araçları (Go kurulu olması gerekir)
go install github.com/jesseduffield/lazydocker@latest

# 6. Zsh varsayılan shell yap
chsh -s $(which zsh)

# 7. Yeni oturum aç (zinit eklentileri otomatik indirir)
exec zsh
```

---

## 🗂 Yapılandırma Dosyaları

| Dosya | Açıklama |
|:---|:---|
| `.zshenv` | ZDOTDIR ve temel env değişkenleri |
| `configs/.zshrc` | Ana giriş noktası, dosyaları source eder |
| `configs/env.zsh` | PATH ve ortam değişkenleri |
| `configs/options.zsh` | Zsh seçenekleri ve FZF ayarları |
| `configs/aliases.zsh` | Alias tanımları |
| `configs/abbr.zsh` | Fish tarzı kısaltmalar (zsh-abbr) |
| `configs/completions.zsh` | Tamamlama sistemi ayarları |
| `configs/plugins.zsh` | Zinit eklenti yüklemeleri |
| `configs/tools.zsh` | CLI araç entegrasyonları (starship, fzf, zoxide vb.) |
| `configs/tmux.zsh` | Otomatik tmux oturumu |
