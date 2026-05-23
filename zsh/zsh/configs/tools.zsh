if command -v starship >/dev/null; then
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
 