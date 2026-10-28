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

# fzf — theme-independent palette: dark gray base + muted orange accent.
# Opaque colors are used deliberately so the fzf UI renders identically
# under any terminal color scheme (light or dark).
export FZF_DEFAULT_OPTS="
 --height=100%
 --layout=reverse
 --border=rounded
 --info=inline
 --pointer=▸
 --marker=▸
 --footer='↑↓ move · enter select · tab mark · esc/ctrl-c cancel'
 --footer-border=line
 --color=bg:#0f1113,bg+:#26282c,gutter:#0f1113
 --color=fg:#a49d94,fg+:#f2efe9
 --color=hl:#d65d0e,hl+:#ffab5e
 --color=header:#d65d0e,info:#8b857d
 --color=prompt:#d65d0e,pointer:#d65d0e,marker:#d65d0e,spinner:#d65d0e
 --color=border:#33363a,preview-border:#33363a,separator:#33363a
 --color=scrollbar:#55585c,preview-scrollbar:#55585c
 --color=footer:#8b857d,footer-border:#33363a
 --color=preview-bg:#0f1113,preview-fg:#a49d94
 --color=query:#f2efe9,disabled:#5a554e
"

# Widget sources (fd-backed) and previews
export FZF_CTRL_T_COMMAND="fd --type f --type l --hidden --follow --exclude .git --exclude node_modules"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=plain {} 2>/dev/null || cat {}' --preview-window='right:50%:border-left'"
export FZF_ALT_C_COMMAND="fd --type d --type l --hidden --follow --exclude .git --exclude node_modules --exclude .cache"
export FZF_ALT_C_OPTS="--preview 'lsd --tree --color=always {} 2>/dev/null || ls -l --color=always {}' --preview-window='right:50%:border-left'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window='right:50%:wrap:border-left'"
export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS --preview 'lsd --color=always --grid {} 2>/dev/null || ls --color=always {}' --preview-window='right:50%:border-left'"

# Local secrets (not tracked by git)
for local_config in "${ZDOTDIR:-$HOME/zsh/configs}/local.zsh" "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/local.zsh"; do
    if [[ -f "$local_config" ]]; then
        source "$local_config"
        break
    fi
done
