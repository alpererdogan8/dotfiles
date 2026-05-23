# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs
. "$HOME/.cargo/env"

export DVM_DIR="/home/polymath/.dvm"
export PATH="$DVM_DIR/bin:$PATH"
. "/home/polymath/.deno/env"
source /home/polymath/.local/share/bash-completion/completions/deno.bash

# Added by LM Studio CLI tool (lms)
export PATH="$PATH:/home/polymath/.lmstudio/bin"
