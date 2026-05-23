export EDITOR=nvim
export VISUAL=nvim
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$BUN_INSTALL/bin:$PNPM_HOME:$HOME/.local/bin:$HOME/bin:$PATH"

function pathprepend() { 
    for ARG in "$@"; do 
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then 
            PATH="$ARG${PATH:+":$PATH"}"
        fi
    done
}
