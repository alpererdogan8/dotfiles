export ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
export EDITOR=nvim
export VISUAL=nvim
export TERMINAL=ghostty

export PATH="$HOME/.local/share/fnm:$PATH"

export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

export STARSHIP_CONFIG="$HOME/.config/starship.toml"
export STARSHIP_CACHE=~/.starship/cache

export NVM_DIR="$HOME/.nvm"

# Local secrets (not tracked by git)
for local_config in "${ZDOTDIR:-$HOME/zsh/configs}/local.zsh" "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/local.zsh"; do
    if [[ -f "$local_config" ]]; then
        source "$local_config"
        break
    fi
done
