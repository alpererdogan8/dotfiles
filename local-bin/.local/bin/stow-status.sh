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
# A package counts as linked when every one of its files resolves into the repo.
# Directories may be linked as a whole, in which case the files inside them are
# real files rather than symlinks; ancestors are therefore checked too.
#
# Two classes of file are left out of the count, because stow would not deploy
# them and their absence at the target is expected rather than a broken link:
# paths ignored by .gitignore (node_modules, __pycache__, .zcompdump,
# zsh_history), and files matched by stow's own ignore rules for that package.
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

# ── Package inventory ───────────────────────────────────────────────────────
# The set of packages and where each one goes is defined in packages.conf, the
# same file install.sh sources. install.sh itself is never sourced here — that
# would run the installer.
#
# packages.conf derives the list from the repository (a top-level directory is a
# package) and only overrides the targets that do not follow the
# ~/.config/<name> convention. So this checker sees exactly the set install.sh
# would act on, and a new directory in the repository shows up in both without
# either script being edited.
PACKAGES_CONF="$DOTFILES_DIR/packages.conf"

if [[ ! -r "$PACKAGES_CONF" ]]; then
  echo "stow-status: package inventory not found: $PACKAGES_CONF" >&2
  echo "stow-status: expected it next to install.sh; the checker and the" >&2
  echo "stow-status: installer have to agree on what counts as a package." >&2
  exit 2
fi

# shellcheck source=../../../packages.conf
source "$PACKAGES_CONF"

declare -A TARGET=()
while IFS=$'\t' read -r _pkg _target; do
  [[ -n "$_pkg" ]] || continue
  TARGET["$_pkg"]="$_target"
done < <(package_pairs "$DOTFILES_DIR")
unset _pkg _target

if [[ "${#TARGET[@]}" -eq 0 ]]; then
  echo "stow-status: no packages found in $DOTFILES_DIR" >&2
  exit 2
fi

# The inventory is derived, so a package can only go missing if a directory is
# not readable. Checking that the two agree keeps a broken override from
# quietly shrinking the set.
for _pkg in "${!TARGET[@]}"; do
  if [[ ! -d "$DOTFILES_DIR/$_pkg" ]]; then
    echo "stow-status: warning: package '$_pkg' resolves to ${TARGET[$_pkg]}" >&2
    echo "stow-status:          but $DOTFILES_DIR/$_pkg does not exist." >&2
  fi
done
unset _pkg

# A repository-root .stow-local-ignore looks like it works and does not: stow
# reads its ignore list from the package directory or from
# ~/.stow-global-ignore, never from the top of the stow directory. Reported in
# the footer rather than as a hard error, because it is only a trap for whoever
# adds the file later.
REPO_ROOT_IGNORE=false
[[ -f "$DOTFILES_DIR/.stow-local-ignore" ]] && REPO_ROOT_IGNORE=true

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

# ── Files GNU Stow never links ──────────────────────────────────────────────
# This ports stow's own ignore algorithm (Stow.pm: ignore(), compile_ignore_
# regexps(), get_ignore_regexps_from_fh()) instead of approximating it. Three
# properties of that algorithm are easy to get wrong and all three change the
# answer, so they are stated here rather than left to the code:
#
#   * Patterns are split into two buckets by whether they contain '/'. A path
#     pattern is tested as "(^|/)(pattern)(/|$)" against "/"+relpath, so it only
#     has to line up with whole '/' -delimited segments and may sit at any
#     depth. A segment pattern is tested as "^(pattern)$" against the basename
#     only. That is why '^/README.*' skips README.md at the package root but
#     not sub/README.md, while '.gitignore' skips at any depth.
#   * The test runs for directories as well as files, and an ignored directory
#     is never descended into. A file is therefore ignored when it, or any
#     ancestor inside the package, matches.
#   * An ignore file *replaces* the built-in list rather than extending it.
#     Dropping a .stow-local-ignore into a package un-protects README.md again.
#
# Verified against stow 2.4.1 by diffing this function's verdicts against
# `stow -nv --no-folding` over a fixture of 30 edge-case filenames; see the
# "Validation" section of CLAUDE.md.
STOW_DEFAULT_IGNORE=(
  'RCS'
  '.+,v'
  'CVS'
  '\.#.+'
  '\.cvsignore'
  '\.svn'
  '_darcs'
  '\.hg'
  '\.git'
  '\.gitignore'
  '\.gitmodules'
  '.+~'
  '#.*#'
  '^/README.*'
  '^/LICENSE.*'
  '^/COPYING'
)

# stow appends this one on top of whichever list it ended up with, so that an
# ignore file can never escape its own package directory. It is therefore not
# part of the built-in list above — a package-local or global list replaces that
# list wholesale, and this entry still has to be there.
STOW_ALWAYS_IGNORE='\.stow-local-ignore$'

# One ignore-file line to one pattern, following stow's parser exactly:
#
#   s/^\s+// ; s/\s+$//          trim
#   next if /^#/ or empty        a line *starting* with '#' is a comment
#   s/\s+#.+//                  a trailing comment needs whitespace before '#'
#   s/\\#/#/g                   unescape '\#' to '#'
#
# The whitespace requirement is what keeps a pattern like '\.#.+' (emacs lock
# files) intact: its '#' has no space in front of it, so it is not a comment.
ignore_pattern() {
  local line="$1"
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"
  [[ -n "$line" && "$line" != \#* ]] || return 1
  line="$(sed -E 's/\s+#.*$//' <<< "$line")"
  line="${line%"${line##*[![:space:]]}"}"
  [[ -n "$line" ]] || return 1
  printf '%s' "${line//\\#/#}"
}

declare -A STOW_IGNORE_CACHE=()

# The effective ignore list for a package, newline separated: the package-local
# file if there is one, else ~/.stow-global-ignore, else stow's built-ins.
# Cached because the answer is identical for every file in a package.
stow_ignore_list() {
  local pkg="$1" src="" f out="" line pat

  if [[ -n "${STOW_IGNORE_CACHE[$pkg]+x}" ]]; then
    printf '%s' "${STOW_IGNORE_CACHE[$pkg]}"
    return 0
  fi

  for f in "$DOTFILES_DIR/$pkg/.stow-local-ignore" "$HOME/.stow-global-ignore"; do
    if [[ -f "$f" ]]; then
      src="$f"
      break
    fi
  done

  if [[ -n "$src" ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
      if pat="$(ignore_pattern "$line")"; then
        out+="$pat"$'\n'
      fi
    done < "$src"
  else
    # Built one line at a time rather than via $(printf ...), which would strip
    # the final newline and glue the next entry onto the last one.
    for pat in "${STOW_DEFAULT_IGNORE[@]}"; do
      out+="$pat"$'\n'
    done
  fi

  out+="^/$STOW_ALWAYS_IGNORE"$'\n'

  STOW_IGNORE_CACHE[$pkg]="$out"
  printf '%s' "$out"
}

# 0 when stow would not deploy <pkg>/<rel>, 1 when it would.
stow_is_ignored() {
  local pkg="$1" rel="$2"
  local list re path base

  list="$(stow_ignore_list "$pkg")"
  [[ -n "$list" ]] || return 1

  # Test the file and then each ancestor in turn, because stow skips an ignored
  # directory without descending into it.
  local -a prefixes=() parts=()
  local acc="" part
  IFS='/' read -r -a parts <<< "$rel"
  for part in "${parts[@]}"; do
    acc="${acc:+$acc/}$part"
    prefixes+=("$acc")
  done
  (( ${#prefixes[@]} )) || return 1

  while IFS= read -r re; do
    [[ -n "$re" ]] || continue
    if [[ "$re" == */* ]]; then
      for path in "${prefixes[@]}"; do
        # shellcheck disable=SC2053  # $re is a regex on purpose, not a glob
        [[ "/$path" =~ (^|/)($re)(/|$) ]] && return 0
      done
    else
      for path in "${prefixes[@]}"; do
        base="${path##*/}"
        # shellcheck disable=SC2053  # $re is a regex on purpose, not a glob
        [[ "$base" =~ ^($re)$ ]] && return 0
      done
    fi
  done <<< "$list"

  return 1
}

# ── Colors ──────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  C_OK=$'\033[32m'; C_WARN=$'\033[1;33m'; C_ERR=$'\033[31m'
  C_DIM=$'\033[2m';  C_OFF=$'\033[0m'; C_BOLD=$'\033[1m'
else
  C_OK=""; C_WARN=""; C_ERR=""; C_DIM=""; C_OFF=""; C_BOLD=""
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
  while [[ -n "$check" && "$check" != "/" && "$check" != "." ]]; do
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
    # Stop when dirname stops making progress. A relative or unexpanded target
    # ($HOME left literal by a quoting mistake, say) collapses to "." down here,
    # and dirname "." is "." — without this the walk never ends and
    # --is-linked hangs instead of reporting a problem.
    local parent
    parent="$(dirname "$check")"
    [[ "$parent" == "$check" ]] && break
    check="$parent"
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

    # Files stow itself would not deploy: repo documentation, plus anything
    # matched by stow's own ignore list for this package.
    if stow_is_ignored "$pkg" "$rel"; then
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
emit '  %s(dim: %d gitignored artifact · %d file stow ignores by its own rules, not deployed)%s\n' \
  "$C_DIM" "$total_skipped" "$total_stow_ignored" "$C_OFF"
if "$REPO_ROOT_IGNORE"; then
  emit '  %s(warn: %s/.stow-local-ignore is not read by stow — use the package dir or ~/.stow-global-ignore)%s\n' \
    "$C_WARN" "$DOTFILES_DIR" "$C_OFF"
fi
emit '%s%s%s\n' "$C_DIM" "──────────────────────────────────────────────────────────────" "$C_OFF"

# ── Inventory ───────────────────────────────────────────────────────────────
# The package set is derived from the repository, so every top-level directory
# is in the table above and none can hide. What is left worth stating is the two
# ways the inventory can be wrong without that showing up in the table:
#
#   * an OVERRIDE_TARGET entry naming a directory that does not exist. Discovery
#     walks directories, so a typo there never produces a package at all — the
#     override is simply inert, and the package would quietly deploy to the
#     convention target instead of the intended one.
#   * a dot-directory. Stow skips these unless run with --dotfiles, so their
#     absence at the target is correct rather than a gap, but it is worth saying
#     which ones there are so the count above can be read correctly.
#
# Reporting only; neither affects the exit status.
declare -a INV_STALE_OVERRIDES=() INV_DOTDIRS=()

for _name in "${!OVERRIDE_TARGET[@]}"; do
  [[ -d "$DOTFILES_DIR/$_name" ]] || \
    INV_STALE_OVERRIDES+=("$_name → ${OVERRIDE_TARGET[$_name]} (no such directory: deploys to the convention target instead)")
done

for _dir in "$DOTFILES_DIR"/.[!.]*/; do
  _dir="${_dir%/}"
  [[ -d "$_dir" ]] || continue
  _name="$(basename "$_dir")"
  [[ "$_name" == ".git" ]] && continue
  _n=$(find "$_dir" -name .git -prune -o -type f -print 2>/dev/null | wc -l)
  INV_DOTDIRS+=("$_name ($_n files)")
done

unset _dir _name _n

emit '\n%sPackage inventory%s\n' "$C_BOLD" "$C_OFF"
emit '  %s%d packages, all discovered from the repository — a new directory is installable with no edit%s\n' \
  "$C_DIM" "${#TARGET[@]}" "$C_OFF"

emit '  %sconvention: ~/.config/<name>%s   %soverrides in packages.conf:%s\n' \
  "$C_DIM" "$C_OFF" "$C_DIM" "$C_OFF"
_inv_list=""
for _name in $(printf '%s\n' "${!OVERRIDE_TARGET[@]}" | sort); do
  _inv_list+="${_inv_list:+ }$_name"
done
emit '    %s%s\n' "$C_DIM" "$_inv_list"
unset _inv_list

if ((${#INV_STALE_OVERRIDES[@]})); then
  emit '  %sOverride with no matching directory — the entry does nothing:%s\n' "$C_ERR" "$C_OFF"
  for _row in "${INV_STALE_OVERRIDES[@]}"; do
    emit '    %s\n' "$_row"
  done
fi

if ((${#INV_DOTDIRS[@]})); then
  emit '  %sDot-directories, not stow packages (stow skips them by design):%s\n' "$C_DIM" "$C_OFF"
  for _row in "${INV_DOTDIRS[@]}"; do
    emit '    %s\n' "$_row"
  done
fi
unset _row

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
