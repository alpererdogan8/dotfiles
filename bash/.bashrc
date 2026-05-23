BASH_CONF_DIR="$HOME/.config/bash"

if [ -f "$BASH_CONF_DIR/env.bash" ]; then . "$BASH_CONF_DIR/env.bash"; fi
if [ -f "$BASH_CONF_DIR/options.bash" ]; then . "$BASH_CONF_DIR/options.bash"; fi
if [ -f "$BASH_CONF_DIR/aliases.bash" ]; then . "$BASH_CONF_DIR/aliases.bash"; fi
if [ -f "$BASH_CONF_DIR/prompt.bash" ]; then . "$BASH_CONF_DIR/prompt.bash"; fi

if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Added by LM Studio CLI tool (lms)
export PATH="$PATH:/home/polymath/.lmstudio/bin"
