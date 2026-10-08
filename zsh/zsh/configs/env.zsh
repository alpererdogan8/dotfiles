export ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
export EDITOR=nvim
export VISUAL=nvim

# NOTE: TERMINAL is deliberately NOT set here. It has a single source of
# truth in dotfiles/uwsm/env, which uwsm's env-preloader injects into the
# systemd user manager at session start — so every shell and every GUI app
# launched in the session already inherits it. Duplicating it here would only
# create a second place to forget when switching terminal emulators.

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
