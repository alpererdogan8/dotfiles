BASH_CONF_DIR="$HOME/.config/bash"

if [ -f "$BASH_CONF_DIR/env.bash" ];     then . "$BASH_CONF_DIR/env.bash";     fi
if [ -f "$BASH_CONF_DIR/options.bash" ]; then . "$BASH_CONF_DIR/options.bash"; fi
if [ -d "$BASH_CONF_DIR/aliases" ]; then
    for _alias_file in "$BASH_CONF_DIR/aliases"/*.bash; do
        [ -f "$_alias_file" ] && . "$_alias_file"
    done
    unset _alias_file
fi
if [ -f "$BASH_CONF_DIR/prompt.bash" ];  then . "$BASH_CONF_DIR/prompt.bash";  fi


if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Added by LM Studio CLI tool (lms)
export PATH="$PATH:/home/polymath/.lmstudio/bin"


# Added by Antigravity CLI installer
export PATH="/home/polymath/.local/bin:$PATH"

. "$HOME/.atuin/bin/env"

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
eval "$(atuin init bash)"
