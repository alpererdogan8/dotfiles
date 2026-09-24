if [[ $- == *i* && -t 0 && -z "$HERDR_ENV" ]] && command -v herdr >/dev/null 2>&1; then
    herdr
fi
