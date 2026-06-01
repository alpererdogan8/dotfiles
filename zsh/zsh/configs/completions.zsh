if [[ ":$FPATH:" != *":$HOME/.zsh/completions:"* ]]; then 
    export FPATH="$HOME/.zsh/completions:$FPATH"
fi

# compinit KALDIRILDI — zinit'in zicompinit'i hallediyor

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd --color=always $realpath 2>/dev/null || ls --color=always $realpath'
zstyle ':omz:plugins:tmux' auto-start yes
zstyle ':omz:plugins:tmux' iterm-name 'default'
