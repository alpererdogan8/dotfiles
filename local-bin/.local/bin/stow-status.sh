#!/usr/bin/env bash

DOTFILES_DIR="$(pwd)"

is_linked() {
  local pkg="$1"
  local file
  file=$(find "$pkg" -mindepth 1 -type f -print -quit 2>/dev/null)
  [ -z "$file" ] && return 1

  local rel="${file#$pkg/}"

  local candidates=(
    "$HOME/.config/$pkg/$rel"
    "$HOME/.config/$rel"
    "$HOME/$rel"
    "/etc/$rel"
    "/etc/$pkg/$rel"
  )

  for candidate in "${candidates[@]}"; do
    local check="$candidate"
    while [[ "$check" != "/" && "$check" != "$HOME" ]]; do
      if [ -L "$check" ]; then
        local resolved
        resolved=$(readlink -f "$check" 2>/dev/null)
        [[ "$resolved" == "${DOTFILES_DIR}/${pkg}/"* || "$resolved" == "${DOTFILES_DIR}/${pkg}" ]] && return 0
      fi
      check="$(dirname "$check")"
    done
  done
  return 1
}

for pkg in */; do
  pkg="${pkg%/}"
  [ -d "$pkg" ] || continue

  if is_linked "$pkg"; then
    echo -e "\e[32m[LINKED  ]\e[0m $pkg"
  else
    echo -e "\e[31m[UNLINKED]\e[0m $pkg"
  fi
done
