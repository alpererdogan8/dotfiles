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

# Notify about the exit status of the last command via desktop notification
# Usage: some-long-command; notify
notify() {
    local status
    status=$([ $? -eq 0 ] && echo "✓ Completed" || echo "✗ Failed")
    local last_cmd
    last_cmd=$(fc -nl -1 | xargs | sed -e 's/;\s*notify$//')
    notify-send --urgency=normal "$status" "$last_cmd"
}

# Fetch a quick cheatsheet from cheat.sh
# Usage: cheat <command>
cheat() {
    curl -s "cheat.sh/$1"
}

# Decode a JWT token and pretty-print header + payload
# Usage: decode-jwt <token>
decode-jwt() {
    jq -R 'split(".") | .[0],.[1] | @base64d | fromjson' <<< "${1}"
}

