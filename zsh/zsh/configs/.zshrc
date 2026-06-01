if [[ -n "$ZSH_PROFILE" ]]; then
    zmodload zsh/zprof
fi

source $ZDOTDIR/env.zsh
source $ZDOTDIR/options.zsh
source $ZDOTDIR/aliases.zsh
source $ZDOTDIR/plugins.zsh
source $ZDOTDIR/tools.zsh
source $ZDOTDIR/tmux.zsh


if [[ -n "$ZSH_PROFILE" ]]; then
    zprof
fi

# pnpm
export PNPM_HOME="/home/polymath/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
