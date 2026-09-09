# 🖥️ Terminal Cheatsheet

---

## ⌨️ Zsh Keybindings

| Key | Description |
|:---|:---|
| `↑` / `↓` | Search history by typed prefix (history-substring-search) |
| `j` / `k` (normal mode) | Navigate history in vi-mode |
| `Ctrl+R` | Fuzzy reverse history search with fzf |
| `Ctrl+T` | Select file with fzf (bat preview) |
| `Ctrl+F` | Change directory (lsd preview) |
| `Alt+C` | Jump to directory with fzf (lsd tree preview) |
| `Tab` | Interactive completion with fzf-tab |
| `Tab Tab` | Navigate completion menu |
| `Esc` | Switch to vi-mode normal mode |
| `i` | Switch to vi-mode insert mode |
| `v` (normal mode) | Edit command in `$EDITOR` |

---

## 🔤 Abbreviations (Expand with Space)

### Git
| Abbreviation | Expands To |
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
| Abbreviation | Expands To |
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

### System & Other
| Abbreviation | Expands To |
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

| Alias | Command |
|:---|:---|
| `c` | `clear` |
| `q` | `exit` |
| `..` | `cd ..` |
| `ls` | `lsd -F --group-dirs first` |
| `ll` | `lsd --all --header --long --group-dirs first` |
| `grep` | `grep --color=auto` |
| `cat` | `bat` (syntax highlighted) |
| `n` / `vi` / `vim` | `nvim` |
| `lvim` | nvim with LazyVim profile |
| `lzd` | `lazydocker` |
| `dt` | `cd ~/dotfiles` |

### Tmux
| Alias | Command |
|:---|:---|
| `tm` | `tmux attach -t main` (creates if not exists) |
| `ta` | `tmux attach -t <name>` |
| `tl` | `tmux list-sessions` |
| `tk` | `tmux kill-session -t <name>` |
| `tnew` | `tmux new-session -s <name>` |

---

## 🛠️ Tool Commands

### zoxide (smart cd)
| Command | Description |
|:---|:---|
| `cd <dir>` | cd via zoxide (learns from history) |
| `cd <partial>` | Finds a previously visited directory by partial name |
| `cdi` | Interactive directory selection with fzf |

### fzf
| Command | Description |
|:---|:---|
| `fzf` | Fuzzy filter via pipe |
| `vim $(fzf)` | Select and open a file with fzf |


### bat (enhanced cat)
| Command | Description |
|:---|:---|
| `cat <file>` | Syntax highlighted viewing |
| `bat --plain <file>` | Plain view without line numbers |
| `bat -A <file>` | Show invisible characters |

### fd (fast find)
| Command | Description |
|:---|:---|
| `fd <name>` | Search files/directories |
| `fd -e py` | Find only `.py` files |
| `fd -H <name>` | Include hidden files |
| `fd -t d <name>` | Search directories only |

### ripgrep (fast grep)
| Command | Description |
|:---|:---|
| `rg <pattern>` | Search content in all files |
| `rg <pattern> -t py` | Search only in Python files |
| `rg -i <pattern>` | Case insensitive search |
| `rg -l <pattern>` | List only file names |

### delta (git diff)
| Command | Description |
|:---|:---|
| `git diff` | Automatic syntax-highlighted diff via delta |
| `git show` | Colorful commit view via delta |

### eza (enhanced ls)
| Command | Description |
|:---|:---|
| `eza` | Colorful listing |
| `eza -la` | Long format, including hidden files |
| `eza --tree` | Tree view |
| `eza --git` | Show git status |

### direnv
| Command | Description |
|:---|:---|
| `echo 'export FOO=bar' > .envrc` | Define project env variable |
| `direnv allow` | Mark `.envrc` as trusted |
| Leaving the directory | Variables are automatically unset |

### thefuck
| Command | Description |
|:---|:---|
| `fuck` | Automatically corrects and reruns the last failed command |

### yazi (file manager)
| Command | Description |
|:---|:---|
| `y` | Open yazi, stay in its directory on exit |
| `hjkl` (inside) | Navigate |
| `Enter` | Open file |
| `Space` | Select |
| `y` → `p` (inside) | Copy → paste |

### lazygit
| Command | Description |
|:---|:---|
| `lg` | Open lazygit TUI |
| `space` (inside) | Stage/unstage |
| `c` (inside) | Commit |
| `P` (inside) | Push |
| `p` (inside) | Pull |

### tmuxifier
| Command | Description |
|:---|:---|
| `tmuxifier new-session <name>` | Create new session layout |
| `tmuxifier load-session <name>` | Load a layout |
| `tmuxifier list` | List saved layouts |

---

## 💡 Tips

> **you-should-use**: If you type a command that has an alias, the terminal will warn you.
> Example: typing `git status` will show `zsh: Found existing alias for "git status". You should use: gss`.

> **autosuggestions**: As you start typing, a dim gray suggestion appears → press `→` to accept.

> **syntax-highlighting**: While typing, valid commands appear **green**, invalid ones appear **red**.
