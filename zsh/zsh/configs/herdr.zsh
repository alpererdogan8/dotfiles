if [[ $- == *i* && -t 0 && -z "$HERDR_ENV" ]]; then
    herdr
fi
