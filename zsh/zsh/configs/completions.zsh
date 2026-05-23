if [[ ":$FPATH:" != *":$HOME/.zsh/completions:"* ]]; then 
    export FPATH="$HOME/.zsh/completions:$FPATH"
fi

autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qNmh+24) ]]; then
    compinit -d "$ZDOTDIR/.zcompdump"
else
    compinit -C -d "$ZDOTDIR/.zcompdump"
fi

zstyle ':omz:plugins:tmux' auto-start yes
zstyle ':omz:plugins:tmux' iterm-name 'default'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd --color=always $realpath 2>/dev/null || ls --color=always $realpath'
