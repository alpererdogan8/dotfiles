shopt -s autocd
shopt -s cdspell
shopt -s checkwinsize
shopt -s histappend
shopt -s globstar

HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
HISTFILE="${XDG_CONFIG_HOME:-$HOME/.config}/bash/bash_history"
