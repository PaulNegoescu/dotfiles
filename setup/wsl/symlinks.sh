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

links=(
  "tilde/.gitconfig|$HOME/.gitconfig"
  "tilde/.gitignore|$HOME/.gitignore"
  "tilde/.gitmessage|$HOME/.gitmessage"
  "tilde/.hushlogin|$HOME/.hushlogin"
  "tilde/.inputrc|$HOME/.inputrc"
  "tilde/.ripgreprc|$HOME/.ripgreprc"
  "tilde/.starship.toml|$HOME/.starship.toml"
  "tilde/.tlrc.toml|$HOME/.tlrc.toml"
  "tilde/.zshenv|$HOME/.zshenv"
  "tilde/.zshrc|$HOME/.zshrc"
  "tilde/.config/bat|$HOME/.config/bat"
  "tilde/.config/btop|$HOME/.config/btop"
  "tilde/.config/eza|$HOME/.config/eza"
  "tilde/.config/hunk|$HOME/.config/hunk"
  "tilde/.ssh/config|$HOME/.ssh/config"
  ".|$HOME/.dotfiles"
)

link_file() {
  local source=$1 destination=$2
  local backup

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
