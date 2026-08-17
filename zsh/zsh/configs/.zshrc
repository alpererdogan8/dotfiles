if [[ -n "$ZSH_PROFILE" ]]; then
    zmodload zsh/zprof
fi

source $ZDOTDIR/env.zsh
source $ZDOTDIR/options.zsh
source $ZDOTDIR/aliases.zsh
source $ZDOTDIR/completions.zsh
source $ZDOTDIR/plugins.zsh
source $ZDOTDIR/tools.zsh
source $ZDOTDIR/abbr.zsh
source $ZDOTDIR/git.zsh
# source $ZDOTDIR/tmux.zsh
source $ZDOTDIR/herdr.zsh

if [[ -n "$ZSH_PROFILE" ]]; then
    zprof
fi

# opencode
export PATH=/home/polymath/.opencode/bin:$PATH
