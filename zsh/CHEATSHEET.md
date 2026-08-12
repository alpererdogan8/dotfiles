# 🖥️ Terminal Cheatsheet

---

## ⌨️ Zsh Keybindings

| Tuş | Ne Yapar |
|:---|:---|
| `↑` / `↓` | Yazdığın prefix'e göre geçmişte arama (history-substring-search) |
| `j` / `k` (normal mod) | vi-mode'da geçmişte gezinme |
| `Ctrl+R` | fzf ile geçmiş araması (fuzzy, reverse search) |
| `Ctrl+T` | fzf ile dosya seç (bat önizlemeli) |
| `Ctrl+F` | Dizin değiştir (lsd önizlemeli) |
| `Alt+C` | fzf ile dizine atla (lsd tree önizlemeli) |
| `Tab` | fzf-tab ile interaktif tamamlama |
| `Tab Tab` | Tamamlama menüsünde gezinme |
| `Esc` | vi-mode normal moda geç |
| `i` | vi-mode insert moda geç |
| `v` (normal mod) | Komutu `$EDITOR`'de düzenle |

---

## 🔤 Abbr Kısaltmaları (Space ile genişler)

### Git
| Kısaltma | Genişler |
|:---|:---|
| `g` | `git` |
| `ga` | `git add` |
| `gaa` | `git add --all` |
| `gcm` | `git commit -m` |
| `gca` | `git commit --amend` |
| `gco` | `git checkout` |
| `gcb` | `git checkout -b` |
| `gd` | `git diff` |
| `gds` | `git diff --staged` |
| `gf` | `git fetch` |
| `gl` | `git pull` |
| `gp` | `git push` |
| `gpf` | `git push --force-with-lease` |
| `gss` | `git status` |
| `gst` | `git stash` |
| `gstp` | `git stash pop` |
| `glog` | `git log --oneline --graph --decorate` |
| `grb` | `git rebase` |
| `grbi` | `git rebase -i` |
| `grs` | `git restore` |
| `grss` | `git restore --staged` |

### Docker
| Kısaltma | Genişler |
|:---|:---|
| `dk` | `docker` |
| `dkc` | `docker compose` |
| `dkcu` | `docker compose up -d` |
| `dkcd` | `docker compose down` |
| `dkcl` | `docker compose logs -f` |
| `dkps` | `docker ps` |
| `dkpsa` | `docker ps -a` |
| `dkrm` | `docker rm` |
| `dkrmi` | `docker rmi` |
| `dkex` | `docker exec -it` |

### Sistem & Diğer
| Kısaltma | Genişler |
|:---|:---|
| `syu` | `sudo dnf upgrade` |
| `syi` | `sudo dnf install` |
| `syr` | `sudo dnf remove` |
| `syss` | `dnf search` |
| `...` | `cd ../..` |
| `....` | `cd ../../..` |
| `e` | `nvim` |
| `lg` | `lazygit` |

---

## 📁 Aliases

| Alias | Komut |
|:---|:---|
| `c` | `clear` |
| `q` | `exit` |
| `..` | `cd ..` |
| `ls` | `lsd -F --group-dirs first` |
| `ll` | `lsd --all --header --long --group-dirs first` |
| `grep` | `grep --color=auto` |
| `cat` | `bat` (syntax highlighted) |
| `n` / `vi` / `vim` | `nvim` |
| `lvim` | LazyVim profiliyle nvim |
| `lzd` | `lazydocker` |
| `dt` | `cd ~/dotfiles` |

### Tmux
| Alias | Komut |
|:---|:---|
| `tm` | `tmux attach -t main` (yoksa oluşturur) |
| `ta` | `tmux attach -t <isim>` |
| `tl` | `tmux list-sessions` |
| `tk` | `tmux kill-session -t <isim>` |
| `tnew` | `tmux new-session -s <isim>` |

---

## 🛠️ Araç Komutları

### zoxide (akıllı cd)
| Komut | Ne Yapar |
|:---|:---|
| `cd <dizin>` | zoxide üzerinden cd (geçmişi öğrenir) |
| `cd <kısmi>` | Daha önce gittiğin dizini kısmi isimle bulur |
| `cdi` | fzf ile interaktif dizin seçimi |

### fzf
| Komut | Ne Yapar |
|:---|:---|
| `fzf` | Pipe ile fuzzy filtre |
| `vim $(fzf)` | fzf ile dosya seçip aç |


### bat (gelişmiş cat)
| Komut | Ne Yapar |
|:---|:---|
| `cat <dosya>` | Syntax highlighted görüntüleme |
| `bat --plain <dosya>` | Satır numarasız sade görünüm |
| `bat -A <dosya>` | Görünmez karakterleri göster |

### fd (hızlı find)
| Komut | Ne Yapar |
|:---|:---|
| `fd <isim>` | Dosya/dizin ara |
| `fd -e py` | Sadece `.py` uzantılıları bul |
| `fd -H <isim>` | Gizli dosyaları da dahil et |
| `fd -t d <isim>` | Sadece dizin ara |

### ripgrep (hızlı grep)
| Komut | Ne Yapar |
|:---|:---|
| `rg <pattern>` | Tüm dosyalarda içerik ara |
| `rg <pattern> -t py` | Sadece Python dosyalarında ara |
| `rg -i <pattern>` | Büyük/küçük harf duyarsız |
| `rg -l <pattern>` | Sadece dosya isimlerini listele |

### delta (git diff)
| Komut | Ne Yapar |
|:---|:---|
| `git diff` | delta ile otomatik syntax-highlighted diff |
| `git show` | delta ile renkli commit görünümü |

### eza (gelişmiş ls)
| Komut | Ne Yapar |
|:---|:---|
| `eza` | Renkli liste |
| `eza -la` | Uzun format, gizli dosyalar dahil |
| `eza --tree` | Ağaç görünümü |
| `eza --git` | Git durumunu da göster |

### direnv
| Komut | Ne Yapar |
|:---|:---|
| `echo 'export FOO=bar' > .envrc` | Proje env değişkeni tanımla |
| `direnv allow` | `.envrc`'yi güvenli olarak işaretle |
| Dizinden çıkınca | Değişkenler otomatik silinir |

### thefuck
| Komut | Ne Yapar |
|:---|:---|
| `fuck` | Son hatalı komutu otomatik düzeltip çalıştırır |

### yazi (dosya yöneticisi)
| Komut | Ne Yapar |
|:---|:---|
| `y` | yazi'yi aç, çıkınca o dizinde kal |
| `hjkl` (içinde) | Gezinme |
| `Enter` | Dosyayı aç |
| `Space` | Seç |
| `y` → `p` (içinde) | Kopyala → yapıştır |

### lazygit
| Komut | Ne Yapar |
|:---|:---|
| `lg` | lazygit TUI'sini aç |
| `space` (içinde) | Stage/unstage |
| `c` (içinde) | Commit |
| `P` (içinde) | Push |
| `p` (içinde) | Pull |

### tmuxifier
| Komut | Ne Yapar |
|:---|:---|
| `tmuxifier new-session <isim>` | Yeni session layout oluştur |
| `tmuxifier load-session <isim>` | Layout'u yükle |
| `tmuxifier list` | Kayıtlı layout'ları listele |

---

## 💡 İpuçları

> **you-should-use**: Bir alias'ın olduğu komutu tam yazarsan terminal seni uyarır.
> Örnek: `git status` yazarsan `zsh: Found existing alias for "git status". You should use: gss` der.

> **autosuggestions**: Yazmaya başladığında soluk gri öneri çıkar → `→` ile kabul et.

> **syntax-highlighting**: Yazarken geçerli komut **yeşil**, hatalı **kırmızı** görünür.
