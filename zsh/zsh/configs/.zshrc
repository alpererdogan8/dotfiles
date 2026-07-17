if [[ -n "$ZSH_PROFILE" ]]; then
    zmodload zsh/zprof
fi

source $ZDOTDIR/env.zsh
source $ZDOTDIR/options.zsh
source $ZDOTDIR/aliases.zsh
source $ZDOTDIR/completions.zsh
source $ZDOTDIR/plugins.zsh
source $ZDOTDIR/tools.zsh
source $ZDOTDIR/tmux.zsh


if [[ -n "$ZSH_PROFILE" ]]; then
    zprof
fi


# opencode
export PATH=/home/polymath/.opencode/bin:$PATH

# fnm
FNM_PATH="/home/polymath/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell zsh)"
fi

. "$HOME/.local/share/../bin/env"
