alias c='clear'
alias q='exit'
alias ..='cd ..'
alias ls='lsd -F --group-dirs first'
alias ll='lsd --all --header --long --group-dirs first'
alias grep='grep --color=auto'

[[ -x "$(command -v nvim)" ]] && alias vi='nvim' && alias vim='nvim'
[[ -x "$(command -v bat)" ]] && alias cat='bat'
