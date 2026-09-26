#!/usr/bin/env bash
#
# stow-status.sh — report the Stow link state of every dotfiles package.
#
# The package → target mapping is read from install.sh (the TARGET map) so this
# script never needs updating when a package is added or retargeted.
#
# Usage:
#   stow-status.sh                 # full report
#   stow-status.sh --brief         # table and summary only, no per-file detail
#   stow-status.sh --quiet         # no output, exit status only (0 = all linked)
#   stow-status.sh ~/dotfiles      # explicit repo path
#   DOTFILES_DIR=~/dotfiles stow-status.sh
#
# A package counts as linked when every one of its tracked files resolves into
# the repo. Directories may be linked as a whole, in which case the files inside
# them are real files rather than symlinks; ancestors are therefore checked too.
# Files ignored by .gitignore (node_modules, __pycache__, .zcompdump,
# zsh_history) are local artifacts and are skipped.
#
# States: LINKED · PARTIAL · CONFLICT · ABSOLUTE · UNLINKED · BROKEN · EMPTY
#
# Exit status: 0 if every package is LINKED or EMPTY, 1 otherwise, 2 on a usage
# or repository discovery error.

set -uo pipefail

usage() {
  cat <<'EOF'
usage: stow-status.sh [--brief|--quiet] [REPO]

  --brief   table and summary only, without per-file details
  --quiet   print nothing, report through the exit status
  REPO      path to the dotfiles repository (default: auto-detected)
EOF
}

BRIEF=false
QUIET=false
REPO_ARG=""

for arg in "$@"; do
  case "$arg" in
    --brief)          BRIEF=true ;;
    --quiet|-q)       QUIET=true ;;
    -h|--help)        usage; exit 0 ;;
    -*)               echo "stow-status: unknown option: $arg" >&2; usage >&2; exit 2 ;;
    *)                REPO_ARG="$arg" ;;
  esac
done

# ── Locate the repository ────────────────────────────────────────────────────
find_repo() {
  local candidate

  if [[ -n "${1:-}" ]]; then
    candidate="$1"
    [[ -f "$candidate/install.sh" ]] || return 1
    printf '%s\n' "$candidate"
    return 0
  fi

  # The installed copy lives at ~/.local/bin/stow-status.sh. Resolve the symlink
  # and walk up so the repo is found wherever it is checked out.
  candidate="$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null)"
  while [[ -n "$candidate" && "$candidate" != "/" ]]; do
    if [[ -f "$candidate/install.sh" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
    candidate="$(dirname "$candidate")"
  done

  if [[ -f "$HOME/dotfiles/install.sh" ]]; then
    printf '%s\n' "$HOME/dotfiles"
    return 0
  fi
  return 1
}

if ! REPO="$(find_repo "$REPO_ARG")"; then
  echo "stow-status: cannot find the dotfiles repo (no install.sh found)" >&2
  echo "stow-status: pass the path as an argument, e.g. stow-status.sh ~/dotfiles" >&2
  exit 2
fi

INSTALL_SH="$REPO/install.sh"
DOTFILES_DIR="$(cd "$(dirname "$INSTALL_SH")" && pwd)"

# ── Read the TARGET map out of install.sh ───────────────────────────────────
# Sourcing install.sh would run the installer, so extract the declare -A block
# and eval it. This relies on that block keeping its current shape.
TARGET_BLOCK="$(awk '/^declare -A TARGET=\(/,/^\)/' "$INSTALL_SH" 2>/dev/null)"

if [[ -z "$TARGET_BLOCK" ]]; then
  echo "stow-status: no 'declare -A TARGET=( ... )' block found in $INSTALL_SH" >&2
  exit 2
fi

eval "$TARGET_BLOCK"

# ── Which repo files are ignored artifacts vs. real content? ─────────────────
declare -A IGNORED=() TRACKED=()

if command -v git >/dev/null && git -C "$DOTFILES_DIR" rev-parse --git-dir >/dev/null 2>&1; then
  while IFS= read -r p; do
    [[ -n "$p" ]] && IGNORED["$p"]=1
  done < <(git -C "$DOTFILES_DIR" ls-files --others --ignored --exclude-standard 2>/dev/null)

  while IFS= read -r p; do
    [[ -n "$p" ]] && TRACKED["$p"]=1
  done < <(git -C "$DOTFILES_DIR" ls-files 2>/dev/null)
fi

# ── Files stow itself never links ───────────────────────────────────────────
# GNU Stow 2.4 skips these by default (verified against stow 2.4.1: it links
# CHANGELOG.md, Makefile, readme.txt and .github/, but not README.md, LICENSE
# or .gitignore). They are repository documentation, not deployed config, so
# their absence at the target is expected rather than a broken link.
#
# Extra patterns can be added in $DOTFILES_DIR/.stow-local-ignore, one glob
# per line, using the same syntax stow itself uses.
stow_ignores() {
  local name="$1" is_dir="$2"

  [[ "$name" == README* || "$name" == LICENSE* || "$name" == LICENCE* || "$name" == COPYING* ]] && return 0
  if [[ "$is_dir" == dir ]]; then
    [[ "$name" == ".git" ]] && return 0
  elif [[ "$name" == .git* ]]; then
    return 0
  fi

  local pattern
  for pattern in "${STOW_LOCAL_IGNORE[@]}"; do
    # shellcheck disable=SC2254  # intentional glob match
    [[ "$name" == $pattern ]] && return 0
  done
  return 1
}

STOW_LOCAL_IGNORE=()
if [[ -f "$DOTFILES_DIR/.stow-local-ignore" ]]; then
  while IFS= read -r line; do
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -n "$line" ]] && STOW_LOCAL_IGNORE+=("$line")
  done < "$DOTFILES_DIR/.stow-local-ignore"
fi

# ── Colors ──────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  C_OK=$'\033[32m'; C_WARN=$'\033[1;33m'; C_ERR=$'\033[31m'
  C_DIM=$'\033[2m';  C_OFF=$'\033[0m'
else
  C_OK=""; C_WARN=""; C_ERR=""; C_DIM=""; C_OFF=""
fi

# ── Classification ──────────────────────────────────────────────────────────
# Prints one of: linked conflict broken missing
#
# A destination is "linked" when it is a symlink into this package, or when any
# of its parent directories is — stow links whole directories when it can, and
# the files reached through that link are real files, not symlinks.
file_state() {
  local src="$1" dest="$2" check resolved link

  check="$dest"
  while [[ -n "$check" && "$check" != "/" ]]; do
    if [[ -L "$check" ]]; then
      resolved="$(readlink -f "$check" 2>/dev/null)"
      if [[ "$resolved" == "$src" || "$resolved" == "$DOTFILES_DIR/$PKG/"* ]]; then
        # Stow only ever creates relative links. An absolute link that still
        # resolves into the repo was made by hand, and stow refuses to touch it
        # ("existing target is not owned by stow"), which aborts the whole
        # package. Resolving alone would hide that, so compare the raw target.
        if [[ "$(readlink "$check")" == /* ]]; then
          printf 'absolute'
        else
          printf 'linked'
        fi
        return
      fi
    fi
    check="$(dirname "$check")"
  done

  if [[ ! -e "$dest" && ! -L "$dest" ]]; then
    printf 'missing'
  elif [[ ! -L "$dest" ]]; then
    printf 'conflict'   # a real file sits where the link should be
  else
    printf 'broken'     # symlink exists, but its target is gone
  fi
}

# ── Report ──────────────────────────────────────────────────────────────────
declare -A PKG_STATE=()
declare -A PKG_PROBLEMS=()
total_linked=0 total_partial=0 total_conflict=0 total_unlinked=0 total_broken=0 total_empty=0
total_skipped=0 total_stow_ignored=0
total_absolute=0

# The check itself always runs so the exit status is meaningful. --quiet
# buffers the report instead of printing it, then writes it to stderr only if
# something is wrong: silence on success is useful in scripts, silence on
# failure would leave no clue what went wrong.
#
# printf -v assigns instead of printing, which avoids a command substitution per
# line. Appending "$(printf ...)" to a variable makes bash read the result as a
# command, so the report fills with "command not found" instead of text.
REPORT=""
emit() {
  if "$QUIET"; then
    local line=""
    printf -v line "$@" 2>/dev/null || line=""
    REPORT+="${line%$'\n'}"$'\n'
    return 0
  fi
  printf "$@"
}

emit '%s%-12s %-32s %-10s %s%s\n' "$C_DIM" "PACKAGE" "TARGET" "FILES" "STATE" "$C_OFF"
emit '%s%s%s\n' "$C_DIM" "──────────── ────────────────────────────── ────────── ─────────" "$C_OFF"

for pkg in $(printf '%s\n' "${!TARGET[@]}" | sort); do
  [[ -d "$DOTFILES_DIR/$pkg" ]] || continue

  PKG="$pkg"
  target="${TARGET[$pkg]}"
  target="${target/#\~/$HOME}"

  n_linked=0; n_conflict=0; n_broken=0; n_missing=0; n_new=0; n_stow_ignored=0; n_absolute=0
  problems=""

  while IFS= read -r src; do
    [[ -n "$src" ]] || continue
    rel="${src#"$DOTFILES_DIR/$pkg"/}"
    repo_rel="$pkg/$rel"

    # Local artifacts (node_modules, caches, history) are not dotfiles content.
    if [[ -n "${IGNORED[$repo_rel]+x}" ]]; then
      total_skipped=$((total_skipped + 1))
      continue
    fi

    # Repository documentation stow never deploys.
    if stow_ignores "$(basename "$src")" file; then
      n_stow_ignored=$((n_stow_ignored + 1))
      total_stow_ignored=$((total_stow_ignored + 1))
      continue
    fi

    state="$(file_state "$src" "$target/$rel")"

    # Untracked but not ignored: new work not committed yet. Worth surfacing,
    # but not a link failure on its own.
    if [[ -z "${TRACKED[$repo_rel]+x}" ]]; then
      n_new=$((n_new + 1))
      problems+="  ${C_DIM}new (uncommitted) ${C_OFF}$repo_rel"$'\n'
    fi

    case "$state" in
      linked)   n_linked=$((n_linked + 1)) ;;
      absolute) n_absolute=$((n_absolute + 1))
                problems+="  ${C_WARN}absolute${C_OFF} $repo_rel → $target/$rel"$'\n' ;;
      conflict) n_conflict=$((n_conflict + 1))
                problems+="  ${C_WARN}conflict${C_OFF}   $repo_rel → $target/$rel"$'\n' ;;
      broken)   n_broken=$((n_broken + 1))
                problems+="  ${C_ERR}broken${C_OFF}     $repo_rel → $target/$rel"$'\n' ;;
      missing)  n_missing=$((n_missing + 1))
                problems+="  ${C_ERR}missing${C_OFF}    $repo_rel → $target/$rel"$'\n' ;;
    esac
  done < <(find "$DOTFILES_DIR/$pkg" -name .git -prune -o -type f -print 2>/dev/null | sort)

  n_files=$((n_linked + n_absolute + n_conflict + n_broken + n_missing))
  files="$n_linked/$n_files"

  if [[ $n_files -eq 0 ]]; then
    PKG_STATE[$pkg]="empty"
    total_empty=$((total_empty + 1))
    state_line="${C_WARN}-${C_OFF} empty"
  elif [[ $n_linked -eq $n_files ]]; then
    PKG_STATE[$pkg]="linked"
    total_linked=$((total_linked + 1))
    state_line="${C_OK}✓ linked${C_OFF}"
  elif [[ $n_linked -eq 0 && $n_broken -eq $n_files ]]; then
    PKG_STATE[$pkg]="broken"
    total_broken=$((total_broken + 1))
    state_line="${C_ERR}✗ broken${C_OFF}"
  elif [[ $n_linked -eq 0 && $n_conflict -eq $n_files ]]; then
    PKG_STATE[$pkg]="conflict"
    total_conflict=$((total_conflict + 1))
    state_line="${C_WARN}⚠ conflict${C_OFF}"
  elif [[ $n_linked -eq 0 && $n_absolute -eq $n_files ]]; then
    PKG_STATE[$pkg]="absolute"
    total_absolute=$((total_absolute + 1))
    state_line="${C_WARN}⚠ absolute${C_OFF}"
  elif [[ $n_linked -eq 0 ]]; then
    PKG_STATE[$pkg]="unlinked"
    total_unlinked=$((total_unlinked + 1))
    state_line="${C_ERR}✗ unlinked${C_OFF}"
  else
    PKG_STATE[$pkg]="partial"
    total_partial=$((total_partial + 1))
    state_line="${C_WARN}! partial${C_OFF}"
  fi

  emit '%s%-12s %-32s %-10s %b\n' "" "$pkg" "$target" "$files" "$state_line"
  PKG_PROBLEMS[$pkg]="$problems"
done

# ── Details for anything that is not fully linked ───────────────────────────
if ! "$BRIEF"; then
  for pkg in $(printf '%s\n' "${!PKG_STATE[@]}" | sort); do
    [[ -n "${PKG_PROBLEMS[$pkg]}" ]] || continue
    emit '\n%s%s%s\n' "$C_DIM" "$pkg" "$C_OFF"
    emit '%s' "${PKG_PROBLEMS[$pkg]}"
  done
fi

emit '\n%s%s%s\n' "$C_DIM" "──────────────────────────────────────────────────────────────" "$C_OFF"
emit '  %s✓ linked %d%s   %s! partial %d%s   %s⚠ conflict %d%s   %s⚠ absolute %d%s   %s✗ unlinked %d%s   %s✗ broken %d%s   %s- empty %d%s\n' \
  "$C_OK"   "$total_linked"   "$C_OFF" \
  "$C_WARN" "$total_partial"   "$C_OFF" \
  "$C_WARN" "$total_conflict"  "$C_OFF" \
  "$C_WARN" "$total_absolute"  "$C_OFF" \
  "$C_ERR"  "$total_unlinked"  "$C_OFF" \
  "$C_ERR"  "$total_broken"    "$C_OFF" \
  "$C_WARN" "$total_empty"     "$C_OFF"
emit '  %s(dim: %d gitignored artifact · %d stow-ignored doc file, not deployed)%s\n' \
  "$C_DIM" "$total_skipped" "$total_stow_ignored" "$C_OFF"
emit '%s%s%s\n' "$C_DIM" "──────────────────────────────────────────────────────────────" "$C_OFF"

rc=0
for pkg in "${!PKG_STATE[@]}"; do
  case "${PKG_STATE[$pkg]}" in
    linked|empty) ;;
    *) rc=1 ;;
  esac
done

if [[ $rc -ne 0 ]] && "$QUIET"; then
  echo "stow-status: not every package is linked; details on stderr, full report with --brief" >&2
  printf '%s' "$REPORT" >&2
fi

exit $rc
