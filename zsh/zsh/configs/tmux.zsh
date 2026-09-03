if [[ -z "$TMUX" && $- == *i* && -t 0 && "$TERM_PROGRAM" != "vscode" ]]; then
    tmux new-session -A -s main
fi
