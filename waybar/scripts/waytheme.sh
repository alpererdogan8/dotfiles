#!/usr/bin/env bash
# waytheme.sh — Set the global theme for float-term.
#
# Usage:
#   waytheme.sh --theme="Everforest Dark Hard"
#   waytheme.sh --theme "Everforest Dark Hard"
#   waytheme.sh -t="Everforest Dark Hard"
#   waytheme.sh -t "Everforest Dark Hard"
#   waytheme.sh              # show the current theme
#   waytheme.sh --list       # list Ghostty themes
#
# The change takes effect on the next float-term invocation (Waybar click);
# no Waybar restart or re-login is required.

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
THEME_FILE="${FLOAT_TERM_THEME_FILE:-$SCRIPT_DIR/float-term.theme}"

usage() {
    cat <<'EOF'
usage: waytheme.sh [options]

options:
  -t, --theme NAME   Set the global theme
  -l, --list         List available Ghostty themes
  -h, --help         Show this help

Without options, the current theme is shown.

example:
  waytheme.sh --theme="Everforest Dark Hard"
  waytheme.sh -t="Everforest Light Med"
EOF
}

theme=""
action="show"

while (( $# )); do
    case $1 in
        -t|--theme)
            [[ $# -ge 2 ]] || { echo "waytheme.sh: --theme requires a value" >&2; exit 2; }
            theme=$2
            action=set
            shift 2
            ;;
        --theme=*|-t=*)
            theme=${1#*=}
            action=set
            shift
            ;;
        -l|--list)
            action=list
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "waytheme.sh: unknown argument: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

# ── List themes ────────────────────────────────────────────────────────────
if [[ $action == list ]]; then
    if ! command -v ghostty >/dev/null 2>&1; then
        echo "waytheme.sh: ghostty not found" >&2
        exit 1
    fi
    ghostty +list-themes 2>/dev/null | sed 's/ (resources)$//'
    exit 0
fi

# ── Show the current theme ─────────────────────────────────────────────────
if [[ $action == show ]]; then
    if [[ -r $THEME_FILE ]]; then
        current=$(
            sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "$THEME_FILE" \
                | grep -m1 -v '^$' || true
        )
        if [[ -n $current ]]; then
            printf '%s\n' "$current"
        else
            echo "waytheme.sh: theme file is empty: $THEME_FILE" >&2
            exit 1
        fi
    else
        echo "waytheme.sh: theme file not found: $THEME_FILE" >&2
        exit 1
    fi
    exit 0
fi

# ── Set the theme ──────────────────────────────────────────────────────────
theme=$(printf '%s' "$theme" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
[[ -n $theme ]] || { echo "waytheme.sh: theme name cannot be empty" >&2; exit 2; }

# Validate the theme: a built-in name, a name in the user theme directory,
# or a direct path to a theme file.
# Note: pipefail + grep -q can produce a false failure via SIGPIPE when grep
# exits early, so the list is captured first.
if command -v ghostty >/dev/null 2>&1; then
    available_themes=$(ghostty +list-themes 2>/dev/null | sed 's/ (resources)$//' || true)

    if [[ -n $available_themes ]]; then
        valid=false
        if [[ $theme == */* && -r $theme ]]; then
            valid=true
        fi
        if [[ -r ${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/themes/$theme ]]; then
            valid=true
        fi
        if grep -Fxq -- "$theme" <<<"$available_themes"; then
            valid=true
        fi

        if [[ $valid != true ]]; then
            echo "waytheme.sh: '$theme' not found." >&2
            echo "             Use: waytheme.sh --list" >&2
            exit 1
        fi
    fi
fi

printf '%s\n' "$theme" > "$THEME_FILE"
printf 'theme set: %s\n' "$theme"
printf 'it will take effect on the next Waybar click.\n'
