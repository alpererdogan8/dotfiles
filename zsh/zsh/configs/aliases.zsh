function pathprepend() { 
    for ARG in "$@"; do 
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then 
            PATH="$ARG${PATH:+":$PATH"}"
        fi
    done
}

pathprepend "$HOME/bin" "$HOME/.local/bin" "$HOME/.cargo/bin"

alias c='clear'
alias q='exit'
alias ..='cd ..'
alias ls='lsd -F --group-dirs first'
alias ll='lsd --all --header --long --group-dirs first'
alias grep='grep --color=auto'
alias lzd='lazydocker'
alias ta='tmux attach -t'
alias tl='tmux list-sessions'
alias tk='tmux kill-session -t'
alias tnew='tmux new-session -s'
alias tm='tmux attach -t main || tmux new-session -s main'

if [[ -x "$(command -v nvim)" ]]; then
    alias n='nvim'
    alias vi='nvim'
    alias vim='nvim'
    alias nvim='nvim'
    alias lvim='NVIM_APPNAME=LazyVim nvim'
fi


alias dt='~/dotfiles'


[[ -x "$(command -v bat)" ]] && alias cat='bat'
