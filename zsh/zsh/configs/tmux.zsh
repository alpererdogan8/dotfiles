if [[ -z "$TMUX" && $- == *i* && -t 0 && "$TERM_PROGRAM" != "vscode" ]]; then
    tmux new-session -A -s main

    if ! tmux has-session -t main 2>/dev/null; then
        exit
    fi
fi
