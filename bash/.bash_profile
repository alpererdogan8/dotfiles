# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

export DVM_DIR="$HOME/.dvm"
export PATH="$DVM_DIR/bin:$PATH"
[[ -f "$HOME/.deno/env" ]] && source "$HOME/.deno/env"
[[ -f "$HOME/.local/share/bash-completion/completions/deno.bash" ]] && \
    source "$HOME/.local/share/bash-completion/completions/deno.bash"

# Added by LM Studio CLI tool (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"


# Added by Antigravity CLI installer
export PATH="$HOME/.local/bin:$PATH"

[[ -f "$HOME/.atuin/bin/env" ]] && source "$HOME/.atuin/bin/env"
