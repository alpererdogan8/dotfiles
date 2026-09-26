#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'
DIM='\033[2m'

DRY_RUN=false
REMOVE=false
RELINK=false
LIST=false
IS_LINKED=false
SELECTED_PACKAGES=()

usage() {
  cat <<'EOF'
usage: install.sh [options] [package ...]

  (no options)      link every package with stow
  --dry-run         show what stow would do, change nothing
  --remove          unlink the given packages (or all)
  --relink          unlink and link again, picking up added or removed files
  --list            table of every package and its link state
  --is-linked       check link state: silent when all linked, exit 0;
                    on failure prints why on stderr and exits 1
  --help            this message

  With no package names the operation applies to every package. The ly package
  targets /etc/ly and is installed with sudo.
EOF
}

for arg in "$@"; do
  case "$arg" in
  --dry-run) DRY_RUN=true ;;
  --remove) REMOVE=true ;;
  --relink) RELINK=true ;;
  --list) LIST=true ;;
  --is-linked) IS_LINKED=true ;;
  -h|--help) usage; exit 0 ;;
  --*)
    echo -e "${RED}Unknown option: $arg${RESET}"
    echo -e "${DIM}Did you mean --list, --is-linked, --dry-run, --relink or --remove?${RESET}"
    usage >&2
    exit 1
    ;;
  *) SELECTED_PACKAGES+=("$arg") ;;
  esac
done

# TARGET: repo/package/file.conf → TARGET/file.conf
# e.g. dotfiles/sway/config → ~/.config/sway/config
declare -A TARGET=(
  [alacritty]="$HOME/.config/alacritty"
  [kitty]="$HOME/.config/kitty"
  [fastfetch]="$HOME/.config/fastfetch"
  [ghostty]="$HOME/.config/ghostty"
  [nvim]="$HOME/.config/nvim"
  [rofi]="$HOME/.config/rofi"
  [sway]="$HOME/.config/sway"
  [kanshi]="$HOME/.config/kanshi"
  [swaync]="$HOME/.config/swaync"
  [systemd]="$HOME/.config/systemd"
  [swayosd]="$HOME/.config/swayosd"
  [swaylock]="$HOME/.config/swaylock"
  [tmux]="$HOME/.config/tmux"
  [uwsm]="$HOME/.config/uwsm"
  [waybar]="$HOME/.config/waybar"
  [starship]="$HOME/.config"
  [bash]="$HOME"
  [git]="$HOME"
  [zsh]="$HOME"
  [vscode]="$HOME"
  ['local-bin']="$HOME"
  [ly]="/etc/ly"
  [yazi]="$HOME/.config/yazi"
)

SUDO_PACKAGES=(ly)

log_ok() { echo -e "${GREEN}[OK]${RESET}    $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
log_error() { echo -e "${RED}[ERROR]${RESET} $*"; }


is_sudo_pkg() {
  local p
  for p in "${SUDO_PACKAGES[@]}"; do [[ "$p" == "$1" ]] && return 0; done
  return 1
}

stow_package() {
  local pkg="$1"
  local target="${TARGET[$pkg]}"

  local flags=(-v -d "$DOTFILES_DIR" -t "$target")
  "$DRY_RUN" && flags+=(-n)
  if "$REMOVE"; then
    flags+=(-D)
  elif "$RELINK"; then
    flags+=(-R)
  else
    flags+=(-S)
  fi

  local action="Linking"
  "$REMOVE" && action="Unlinking"
  "$RELINK" && action="Relinking"
  "$DRY_RUN" && action="[DRY] $action"
  echo -e "\n${BOLD}${action}:${RESET} ${CYAN}${pkg}${RESET} → ${target}"

  if [[ ! -d "$target" ]]; then
    if "$DRY_RUN"; then
      log_warn "Target does not exist: $target"
    else
      if is_sudo_pkg "$pkg"; then
        sudo mkdir -p "$target"
      else
        mkdir -p "$target"
      fi
    fi
  fi

  local rc=0
  if is_sudo_pkg "$pkg"; then
    log_warn "Running with sudo"
    if "$DRY_RUN"; then
      echo "  → sudo stow ${flags[*]} $pkg"
    else
      sudo stow "${flags[@]}" "$pkg" || rc=$?
    fi
  else
    stow "${flags[@]}" "$pkg" || rc=$?
  fi

  if [[ $rc -ne 0 ]]; then
    log_error "$pkg stow error (exit: $rc)"
    return $rc
  fi

  log_ok "$pkg done"
}

if ! command -v stow &>/dev/null; then
  echo -e "${RED}GNU Stow not found. Install: sudo dnf install stow${RESET}"
  exit 1
fi

# Link state is owned by stow-status.sh, which reads the TARGET map above, so
# there is a single definition of "linked" for both --list and --is-linked.
LINK_CHECKER="$DOTFILES_DIR/local-bin/.local/bin/stow-status.sh"

if "$LIST" || "$IS_LINKED"; then
  if [[ ! -x "$LINK_CHECKER" ]]; then
    echo -e "${RED}Link checker not found: $LINK_CHECKER${RESET}"
    exit 2
  fi
  if "$DRY_RUN"; then
    echo -e "${YELLOW}Note: reporting current link state; --dry-run does not simulate it${RESET}"
  fi
  if "$IS_LINKED"; then
    "$LINK_CHECKER" --quiet "$DOTFILES_DIR"
  else
    "$LINK_CHECKER" --brief "$DOTFILES_DIR"
  fi
  exit $?
fi

echo -e "\n${BOLD}══════════════════════════════════════${RESET}"
echo -e "${BOLD}  Dotfiles  │  ${DOTFILES_DIR}${RESET}"
"$DRY_RUN" && echo -e "${YELLOW}  Mode: DRY RUN (no changes will be made)${RESET}"
"$REMOVE" && echo -e "${RED}  Mode: REMOVE (links will be removed)${RESET}"
"$RELINK" && echo -e "${CYAN}  Mode: RELINK (existing links will be re-created)${RESET}"
echo -e "${BOLD}══════════════════════════════════════${RESET}"

if [[ ${#SELECTED_PACKAGES[@]} -gt 0 ]]; then
  PACKAGES=("${SELECTED_PACKAGES[@]}")
else
  PACKAGES=("${!TARGET[@]}")
fi

ERRORS=0
ok=0
total=0
skipped=0
for pkg in "${PACKAGES[@]}"; do
  if [[ -z "${TARGET[$pkg]+_}" ]]; then
    log_error "Undefined package: '$pkg'"
    ERRORS=$((ERRORS + 1))
    continue
  fi
  if [[ ! -d "$DOTFILES_DIR/$pkg" ]]; then
    log_warn "Directory not found, skipping: $pkg"
    skipped=$((skipped + 1))
    continue
  fi

  total=$((total + 1))
  if stow_package "$pkg"; then
    ok=$((ok + 1))
  else
    ERRORS=$((ERRORS + 1))
  fi
done

echo -e "\n${BOLD}══════════════════════════════════════${RESET}"
if [[ $ERRORS -eq 0 && $skipped -eq 0 ]]; then
  echo -e "${GREEN}${BOLD}  ✓ $ok/$total packages processed successfully${RESET}"
elif [[ $ERRORS -eq 0 ]]; then
  echo -e "${GREEN}${BOLD}  ✓ $ok/$total packages processed successfully${RESET} ${YELLOW}│ $skipped skipped${RESET}"
else
  echo -e "${YELLOW}${BOLD}  ⚠ $ok/$total succeeded │ $ERRORS errors${RESET}"
  [[ $skipped -gt 0 ]] && echo -e "${YELLOW}  $skipped packages skipped${RESET}"
fi
echo -e "${BOLD}══════════════════════════════════════${RESET}\n"

exit $ERRORS
