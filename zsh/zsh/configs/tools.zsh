if command -v fnm > /dev/null; then
    eval "$(fnm env --use-on-cd --shell zsh)"
fi


if command -v starship > /dev/null; then
    eval "$(starship init zsh)"
fi

zinit wait"0" lucid id-as"fzf-keybinds" for \
    atload'source <(fzf --zsh)' \
    zdharma-continuum/null

zinit wait"0" lucid id-as"zoxide-init" for \
    atload'eval "$(zoxide init --cmd cd zsh)"' \
    zdharma-continuum/null

zinit lucid id-as"tmuxifier-init" \
    atload'ln -sf ${ZINIT[PLUGINS_DIR]}/tmuxifier-init $HOME/.tmuxifier; source $HOME/.tmuxifier/init.sh' for \
    jimeh/tmuxifier

# Automatically load/unload .envrc files when entering/leaving directories
if command -v direnv > /dev/null; then
    zinit wait"0" lucid id-as"direnv-hook" for \
        atload'eval "$(direnv hook zsh)"' \
        zdharma-continuum/null
fi

# Corrects previous mistyped commands (e.g. type 'f' after an error)
if command -v pay-respects > /dev/null; then
    zinit wait"1" lucid id-as"pay-respects-init" for \
        atload'eval "$(pay-respects zsh)"' \
        zdharma-continuum/null
fi
