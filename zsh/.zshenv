export ZDOTDIR=$HOME/zsh/configs

export PATH="$HOME/.local/bin:$PATH"
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME/bin:$PATH"

# opencode CLI
[[ -d "$HOME/.opencode/bin" ]] && export PATH="$HOME/.opencode/bin:$PATH"
