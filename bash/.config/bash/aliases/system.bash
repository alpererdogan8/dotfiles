# System safety & quality-of-life aliases and functions

# Safe deletion — moves to trash instead of permanently removing
[[ -x "$(command -v trash)" ]] && alias rm='trash'

# Copy the last executed command to the Wayland clipboard
alias cphist='fc -ln -1 | wl-copy'

# Jump to a fresh temporary directory
cdtmp() {
    cd "$(mktemp -d)" || return 1
}

# Yazi file manager wrapper — cd to the last visited directory on exit
yy() {
    local tmp
    tmp="$(mktemp)"
    yazi --cwd-file="$tmp" "$@"
    if [[ -f "$tmp" && -s "$tmp" ]]; then
        cd "$(cat "$tmp")" || return 1
    fi
    rm -f "$tmp"
}
