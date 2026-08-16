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

alias ls='eza --icons --group-directories-first'
alias ll='eza --icons --all --long --git --group-directories-first'
alias lt='eza --icons --tree --level=2'

alias grep='grep --color=auto'
alias lzd='lazydocker'
alias ta='tmux attach -t'
alias tl='tmux list-sessions'
alias tk='tmux kill-session -t'
alias tnew='tmux new-session -s'
alias tm='tmux attach -t main || tmux new-session -s main'
alias dt='cd ~/dotfiles'

# Safe deletion — moves to trash instead of permanently removing
[[ -x "$(command -v trash)" ]] && alias rm='trash'

# Copy the last executed command to the Wayland clipboard
alias cphist='fc -ln -1 | wl-copy'

# Jump to a fresh temporary directory
cdtmp() {
    cd "$(mktemp -d)" || return 1
}


if [[ -x "$(command -v nvim)" ]]; then
    alias n='nvim'
    alias vi='nvim'
    alias vim='nvim'
    alias nvim='nvim'
    alias lvim='NVIM_APPNAME=LazyVim nvim'
fi

[[ -x "$(command -v bat)" ]] && alias cat='bat'
