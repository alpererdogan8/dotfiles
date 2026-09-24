# Interactive fzf-powered git helpers
# Requires: git, fzf

# Returns non-zero if the current directory is not inside a git repository
_git_is_repo() {
    command -v git > /dev/null 2>&1 && command -v fzf > /dev/null 2>&1 && git rev-parse HEAD > /dev/null 2>&1
}

# gb — interactive branch switcher
# Lists all local and remote branches with a log preview; checks out the selection
gb() {
    _git_is_repo || return

    local branch
    branch=$(
        git branch -a --color=always \
            | grep -v '/HEAD\s' \
            | sort \
            | fzf --ansi --tac \
                  --header "Current: $(git rev-parse --abbrev-ref HEAD)" \
                  --preview-window 'right:60%' \
                  --preview 'git log --oneline --graph --date=short --color=always \
                      --pretty="format:%C(auto)%cd %h%d %s" \
                      $(sed s/^..// <<< {} | cut -d" " -f1) 2>/dev/null | head -50' \
            | sed 's/^..//' \
            | cut -d' ' -f1 \
            | sed 's#^remotes/##'
    )

    [[ -n "$branch" ]] && git checkout "$branch"
}

# gl — interactive git log browser
# Browse commits with a full diff preview; Enter copies the hash to clipboard
gl() {
    _git_is_repo || return

    local selection hash
    selection=$(git log \
        --date=short \
        --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" \
        --graph \
        --color=always \
    | fzf --ansi --no-sort --reverse \
          --preview-window 'right:60%' \
          --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | head -1 \
              | xargs git show --color=always 2>/dev/null | head -200') || return
    [[ -n "$selection" ]] || return
    hash=$(printf '%s' "$selection" | grep -o '[a-f0-9]\{7,\}' | head -1)
    if command -v wl-copy > /dev/null 2>&1; then
        printf '%s' "$hash" | wl-copy
    elif command -v xclip > /dev/null 2>&1; then
        printf '%s' "$hash" | xclip -selection clipboard
    else
        printf '%s\n' "$selection"
    fi
}

# gt — interactive tag selector with show preview
gt() {
    _git_is_repo || return

    local tag
    tag=$(git tag --sort -version:refname \
    | fzf --preview-window 'right:60%' \
          --preview 'git show --color=always {} 2>/dev/null | head -200') || return
    [[ -n "$tag" ]] && git show --color=always "$tag"
}
