ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
  print -P "%F{yellow}Zinit not found, installing...%f"
  command mkdir -p "$(dirname $ZINIT_HOME)"
  command git clone https://github.com/zdharma-continuum/zinit "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

function zvm_config() {
    ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
    ZVM_CURSOR_STYLE_ENABLED=true
    ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
    ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
    ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_UNDERLINE
}

# Bind history-substring-search after vi-mode initializes to prevent key conflicts
function zvm_after_init() {
    bindkey '^[[A' history-substring-search-up    # Up arrow
    bindkey '^[[B' history-substring-search-down  # Down arrow
    bindkey -M vicmd 'k' history-substring-search-up
    bindkey -M vicmd 'j' history-substring-search-down
}

zinit lucid depth"1" for \
    jeffreytse/zsh-vi-mode

zinit lucid blockf for \
    zsh-users/zsh-completions

autoload -Uz compinit
# Only regenerate .zcompdump once every 24 hours — skips full filesystem scan on other startups
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit -d "${ZDOTDIR}/.zcompdump"   # Full regeneration (once a day)
else
    compinit -C -d "${ZDOTDIR}/.zcompdump" # Fast load from cache (no disk scan)
fi

zinit lucid for \
    Aloxaf/fzf-tab

zinit wait"0c" lucid atload"_zsh_autosuggest_start" for \
    zsh-users/zsh-autosuggestions

zinit wait"1" lucid atload"ZSH_HIGHLIGHT_STYLES[comment]='fg=#ffffff,bold'" for \
    zsh-users/zsh-syntax-highlighting

# Fish-like abbreviation system: expansions are visible in history unlike aliases
# abbr.zsh is sourced via atload to ensure zsh-abbr is ready before definitions run
zinit wait"1" lucid atload"source \$ZDOTDIR/abbr.zsh" for \
    olets/zsh-abbr

# Prefix-based history search with up/down arrows (Fish-like behavior)
zinit wait"1" lucid atload'HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="bg=cyan,fg=black,bold"; HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND="bg=red,fg=white,bold"' for \
    zsh-users/zsh-history-substring-search

# Reminds you when a shorter alias exists for the command you just typed
zinit wait"2" lucid for \
    MichaelAquilina/zsh-you-should-use

zinit wait"2" lucid for \
    OMZP::git \
    OMZP::sudo \
    OMZP::command-not-found

zinit wait"3" lucid for \
    OMZP::docker

function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
