export ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
export EDITOR=nvim
export VISUAL=nvim
export TERMINAL=ghostty

export GOPATH=$HOME/go
export PATH=$PATH:$(go env GOPATH)/bin
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
export STARSHIP_CACHE=~/.starship/cache
