#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

DRY_RUN=false
REMOVE=false
LIST=false
SELECTED_PACKAGES=()

for arg in "$@"; do
  case "$arg" in
  --dry-run) DRY_RUN=true ;;
  --remove) REMOVE=true ;;
  --list) LIST=true ;;
  --*)
    echo -e "${RED}Unknown option: $arg${RESET}"
    exit 1
    ;;
  *) SELECTED_PACKAGES+=("$arg") ;;
  esac
done

# TARGET: repo/package/file.conf → TARGET/file.conf
# e.g. dotfiles/hypr/hypr.conf → ~/.config/hypr/hypr.conf
declare -A TARGET=(
  [alacritty]="$HOME/.config/alacritty"
  [kitty]="$HOME/.config/kitty"
  [fastfetch]="$HOME/.config/fastfetch"
  [ghostty]="$HOME/.config/ghostty"
  [hypr]="$HOME/.config/hypr"
  [nvim]="$HOME/.config/nvim"
  [rofi]="$HOME/.config/rofi"
  [sway]="$HOME/.config/sway"
  [swaync]="$HOME/.config/swaync"
  [swayosd]="$HOME/.config/swayosd"
  [tmux]="$HOME/.config/tmux"
  [uwsm]="$HOME/.config/uwsm"
  [waybar]="$HOME/.config/waybar"
  [starship]="$HOME/.config"
  [bash]="$HOME"
  [git]="$HOME"
  [zsh]="$HOME"
  [vscode]="$HOME"
  ['local-bin']="$HOME"
  [themes]="$HOME"
  [tmuxifier]="$HOME"
  [ly]="/etc/ly"
  [yazi]="$HOME/.config/yazi"
  ['snappy-switcher']="$HOME/.config/snappy-switcher"
)

SUDO_PACKAGES=(ly)

log_ok() { echo -e "${GREEN}[OK]${RESET}    $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
log_error() { echo -e "${RED}[ERROR]${RESET} $*"; }

list_packages() {
  local pkg target first_file rel_path target_path link_dest
  local installed=0 missing=0 conflict=0

  echo -e "\n${BOLD}══════════════════════════════════════════════════════${RESET}"
  echo -e "${BOLD}  Dotfiles  │  ${DOTFILES_DIR}${RESET}"
  echo -e "${BOLD}══════════════════════════════════════════════════════${RESET}"
  printf "\n${BOLD}  %-20s %-30s %s${RESET}\n" "PACKAGE" "TARGET" "STATUS"
  printf "  %-20s %-30s %s\n" "──────────────────" "────────────────────────────" "──────────────"

  for pkg in $(echo "${!TARGET[@]}" | tr ' ' '\n' | sort); do
    if [[ ! -d "$DOTFILES_DIR/$pkg" ]]; then
      continue
    fi
    target="${TARGET[$pkg]}"

    # Check all top-level files — stow links at this level first.
    # A package is "installed" if ANY top-level file is properly symlinked.
    # Fall back to any depth if the package has no top-level files (dirs only).
    local status="missing" probe rel_path target_path link_dest
    local search_depth="-maxdepth 1"
    mapfile -t top_files < <(find "$DOTFILES_DIR/$pkg" -maxdepth 1 -type f 2>/dev/null)
    [[ ${#top_files[@]} -eq 0 ]] && mapfile -t top_files < <(find "$DOTFILES_DIR/$pkg" -type f 2>/dev/null)

    if [[ ${#top_files[@]} -eq 0 ]]; then
      printf "  ${CYAN}%-20s${RESET} %-30s ${YELLOW}EMPTY${RESET}\n" "$pkg" "$target"
      continue
    fi

    for probe in "${top_files[@]}"; do
      rel_path="${probe#$DOTFILES_DIR/$pkg/}"
      target_path="$target/$rel_path"
      if [[ -L "$target_path" ]]; then
        link_dest=$(readlink -f "$target_path")
        if [[ "$link_dest" == "$probe" ]]; then
          status="installed"
          break
        else
          status="conflict"
        fi
      elif [[ -e "$target_path" ]] && [[ "$status" == "missing" ]]; then
        status="conflict"
      fi
    done

    case "$status" in
    installed)
      printf "  ${GREEN}%-20s${RESET} %-30s ${GREEN}✓ installed${RESET}\n" "$pkg" "$target"
      installed=$((installed + 1))
      ;;
    conflict)
      printf "  ${YELLOW}%-20s${RESET} %-30s ${YELLOW}⚠ exists (not symlink)${RESET}\n" "$pkg" "$target"
      conflict=$((conflict + 1))
      ;;
    missing)
      printf "  ${RED}%-20s${RESET} %-30s ${RED}✗ not installed${RESET}\n" "$pkg" "$target"
      missing=$((missing + 1))
      ;;
    esac
  done

  echo -e "\n${BOLD}══════════════════════════════════════════════════════${RESET}"
  echo -e "  ${GREEN}✓ installed: $installed${RESET}  ${RED}✗ missing: $missing${RESET}  ${YELLOW}⚠ conflict: $conflict${RESET}"
  echo -e "${BOLD}══════════════════════════════════════════════════════${RESET}\n"
}

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
  else
    flags+=(-R)
  fi

  local action="Linking"
  "$REMOVE" && action="Unlinking"
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

if "$LIST"; then
  list_packages
  exit 0
fi

echo -e "\n${BOLD}══════════════════════════════════════${RESET}"
echo -e "${BOLD}  Dotfiles  │  ${DOTFILES_DIR}${RESET}"
"$DRY_RUN" && echo -e "${YELLOW}  Mode: DRY RUN (no changes will be made)${RESET}"
"$REMOVE" && echo -e "${RED}  Mode: REMOVE (links will be removed)${RESET}"
echo -e "${BOLD}══════════════════════════════════════${RESET}"

if [[ ${#SELECTED_PACKAGES[@]} -gt 0 ]]; then
  PACKAGES=("${SELECTED_PACKAGES[@]}")
else
  PACKAGES=("${!TARGET[@]}")
fi

ERRORS=0
for pkg in "${PACKAGES[@]}"; do
  if [[ -z "${TARGET[$pkg]+_}" ]]; then
    log_error "Undefined package: '$pkg'"
    ((ERRORS++))
    continue
  fi
  if [[ ! -d "$DOTFILES_DIR/$pkg" ]]; then
    log_warn "Directory not found, skipping: $pkg"
    continue
  fi

  stow_package "$pkg" || ((ERRORS++))
done

echo -e "\n${BOLD}══════════════════════════════════════${RESET}"
total="${#PACKAGES[@]}"
ok=$((total - ERRORS))
if [[ $ERRORS -eq 0 ]]; then
  echo -e "${GREEN}${BOLD}  ✓ $ok/$total packages processed successfully${RESET}"
else
  echo -e "${YELLOW}${BOLD}  ⚠ $ok/$total succeeded │ $ERRORS errors${RESET}"
fi
echo -e "${BOLD}══════════════════════════════════════${RESET}\n"

exit $ERRORS
