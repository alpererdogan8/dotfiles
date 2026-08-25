# =============================================================================
# Abbreviation System (Fish-like abbr) — zsh-abbr
# Flags must be passed separately (combined flags like -qS not supported):
#   -q : quiet — no output
#   -S : session — no disk writes; definitions live here in the dotfile
# =============================================================================

# --- Git abbreviations ---
abbr -q -S g="git"
abbr -q -S ga="git add"
abbr -q -S gaa="git add --all"
abbr -q -S gcm="git commit -m"        # gc conflicts with a system command
abbr -q -S gca="git commit --amend"
abbr -q -S gco="git checkout"
abbr -q -S gcb="git checkout -b"
abbr -q -S gd="git diff"
abbr -q -S gds="git diff --staged"
abbr -q -S gf="git fetch"
abbr -q -S gl="git pull"
abbr -q -S gp="git push"
abbr -q -S gpf="git push --force-with-lease"
abbr -q -S gss="git status"           # gs conflicts with ghostscript
abbr -q -S gst="git stash"
abbr -q -S gstp="git stash pop"
abbr -q -S glog="git log --oneline --graph --decorate"
abbr -q -S grb="git rebase"
abbr -q -S grbi="git rebase -i"
abbr -q -S grs="git restore"
abbr -q -S grss="git restore --staged"

# --- Docker abbreviations ---
abbr -q -S dk="docker"
abbr -q -S dkc="docker compose"
abbr -q -S dkcu="docker compose up -d"
abbr -q -S dkcd="docker compose down"
abbr -q -S dkcl="docker compose logs -f"
abbr -q -S dkps="docker ps"
abbr -q -S dkpsa="docker ps -a"
abbr -q -S dkrm="docker rm"
abbr -q -S dkrmi="docker rmi"
abbr -q -S dkex="docker exec -it"

# --- System / Package manager abbreviations (Fedora) ---
abbr -q -S syu="sudo dnf upgrade"
abbr -q -S syi="sudo dnf install"
abbr -q -S syr="sudo dnf remove"
abbr -q -S syss="dnf search"

# --- Navigation abbreviations ---
abbr -q -S ...="cd ../.."
abbr -q -S ....="cd ../../.."

# --- Editor / Tool abbreviations ---
abbr -q -S e="nvim"
abbr -q -S lg="lazygit"
abbr -q -S grep="rg"
