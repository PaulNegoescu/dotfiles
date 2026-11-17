#!/usr/bin/env bash

set -euo pipefail

DRY_RUN=false
case "${1:-}" in
  --dry-run) DRY_RUN=true ;;
  "") ;;
  *)
    echo "Usage: $0 [--dry-run]" >&2
    exit 1
    ;;
esac

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"

TILDE_DIR="$DOTFILES_DIR/tilde"

# Files in tilde/ that are not dotfiles to link
EXCLUDE_FILES=(".DS_Store" "README.md" ".ssh")

# ~/.config entries that only make sense on macOS
MACOS_ONLY_CONFIG=("ghostty" "cmux")

contains() {
  local needle=$1 item
  shift
  for item in "$@"; do
    [ "$item" = "$needle" ] && return 0
  done
  return 1
}

# Discover links the same way setup/symlinks.sh does on macOS, so new files in
# tilde/ are picked up on both platforms without maintaining a second list.
links=()
shopt -s dotglob nullglob
for item_path in "$TILDE_DIR"/*; do
  item=${item_path##*/}
  contains "$item" "${EXCLUDE_FILES[@]}" && continue

  if [ "$item" = ".config" ]; then
    for config_path in "$item_path"/*; do
      config_item=${config_path##*/}
      contains "$config_item" "${MACOS_ONLY_CONFIG[@]}" && continue
      links+=("tilde/.config/$config_item|$HOME/.config/$config_item")
    done
  else
    links+=("tilde/$item|$HOME/$item")
  fi
done
shopt -u dotglob nullglob

# Link only SSH configuration; preserve keys and other SSH files
links+=("tilde/.ssh/config|$HOME/.ssh/config")
# Stable path for configs, regardless of where the repository is cloned
links+=(".|$HOME/.dotfiles")

# OpenSSH refuses a config that others can write, and files under /mnt/c show
# up as mode 777, so a symlink into a repository on the Windows drive cannot
# work. Copy the file instead; re-run this script after editing it.
copy_ssh_config() {
  local source=$1 destination=$2
  local backup

  if [ ! -L "$destination" ] && [ -f "$destination" ] && cmp -s "$source" "$destination"; then
    chmod 600 "$destination"
    echo "Already up to date: $destination"
    return
  fi

  if [ -e "$destination" ] || [ -L "$destination" ]; then
    backup="$destination.backup.$(date +%Y%m%d%H%M%S)"
    mv "$destination" "$backup"
    echo "Backed up $destination to $backup"
  fi

  install -m 600 "$source" "$destination"
  echo "Copied $destination"
}

link_file() {
  local source=$1 destination=$2
  local backup

  if [ ! -e "$source" ] && [ ! -L "$source" ]; then
    echo "Skipped (source is missing): $source" >&2
    return
  fi

  if [ "$DRY_RUN" = true ]; then
    if [ -L "$destination" ] && [ "$(readlink "$destination")" = "$source" ]; then
      echo "[dry-run] already linked: $destination"
    elif [ -e "$destination" ] || [ -L "$destination" ]; then
      echo "[dry-run] would back up and replace: $destination"
    else
      echo "[dry-run] would link: $destination -> $source"
    fi
    return
  fi

  mkdir -p "$(dirname "$destination")"
  if [ "$destination" = "$HOME/.ssh/config" ]; then
    chmod 700 "$HOME/.ssh"
    copy_ssh_config "$source" "$destination"
    return
  fi

  if [ -L "$destination" ] && [ "$(readlink "$destination")" = "$source" ]; then
    echo "Already linked: $destination"
    return
  fi

  if [ -e "$destination" ] || [ -L "$destination" ]; then
    backup="$destination.backup.$(date +%Y%m%d%H%M%S)"
    mv "$destination" "$backup"
    echo "Backed up $destination to $backup"
  fi

  ln -s "$source" "$destination"
  echo "Linked $destination"
}

for mapping in "${links[@]}"; do
  source_path=${mapping%%|*}
  destination_path=${mapping#*|}

  if [ "$source_path" = "." ]; then
    source_path=$DOTFILES_DIR
  else
    source_path="$DOTFILES_DIR/$source_path"
  fi

  link_file "$source_path" "$destination_path"
done
