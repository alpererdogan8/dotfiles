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

zinit lucid depth"1" for \
    jeffreytse/zsh-vi-mode

zinit wait"0a" lucid blockf for \
    zsh-users/zsh-completions

zinit wait"0b" lucid for \
    Aloxaf/fzf-tab

zinit wait"0c" lucid atload"_zsh_autosuggest_start" for \
    zsh-users/zsh-autosuggestions

zinit wait"1" lucid for \
    zsh-users/zsh-syntax-highlighting

zinit wait"2" lucid for \
    OMZP::git \
    OMZP::sudo \
    OMZP::command-not-found

zinit wait"3" lucid for \
    OMZP::docker



# fnm
eval "$(fnm env --use-on-cd --shell zsh)"

zinit wait"0a" lucid blockf for \
    zsh-users/zsh-completions
