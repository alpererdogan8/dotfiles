export ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
export EDITOR=nvim
export VISUAL=nvim
export TERMINAL=ghostty

export PATH="$HOME/.local/share/fnm:$PATH"

export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

export STARSHIP_CONFIG="$HOME/.config/starship.toml"
export STARSHIP_CACHE=~/.starship/cache

export NVM_DIR="$HOME/.config/nvm"

# Local secrets (not tracked by git)
[[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/local.zsh" ]] && \
    source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/local.zsh"
