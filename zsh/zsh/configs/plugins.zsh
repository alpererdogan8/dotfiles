
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
  print -P "%F{yellow}Zinit not found, installing...%f"
  command mkdir -p "$(dirname $ZINIT_HOME)"
  command git clone https://github.com/zdharma-continuum/zinit "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"


if [[ ":$FPATH:" != *":/home/polymath/.zsh/completions:"* ]]; then
    export FPATH="/home/polymath/.zsh/completions:$FPATH"
fi


zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd --color=always $realpath 2>/dev/null || ls --color=always $realpath'

zstyle ':omz:plugins:tmux' auto-start yes
zstyle ':omz:plugins:tmux' iterm-name 'default'


function zvm_config() {
    ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
    ZVM_CURSOR_STYLE_ENABLED=true
    ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
    ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
    ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_UNDERLINE
}


zinit lucid depth"1" for \
    jeffreytse/zsh-vi-mode

zinit wait"0a" lucid blockf for \
    zsh-users/zsh-completions

zinit wait"0b" lucid for \
    Aloxaf/fzf-tab

zinit wait"0c" lucid atload"_zsh_autosuggest_start" for \
    zsh-users/zsh-autosuggestions


zinit wait"1" lucid atinit"zicompinit; zicdreplay" for \
    zdharma-continuum/fast-syntax-highlighting

zinit wait"2" lucid for \
    OMZP::git \
    OMZP::sudo \
    OMZP::command-not-found

zinit wait"3" lucid for \
    OMZP::docker


zinit wait"5" lucid is-snippet for \
    "$NVM_DIR/nvm.sh"
