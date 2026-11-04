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

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
extension_file="$DOTFILES_DIR/vscode/extensions/wsl.txt"

if [ "$DRY_RUN" = false ] && ! command -v code > /dev/null 2>&1; then
  echo "VS Code's WSL command is unavailable. Open this distro once with 'WSL: Connect to WSL', then retry." >&2
  exit 1
fi

while IFS= read -r extension; do
  case "$extension" in
    "" | \#*) continue ;;
  esac

  if [ "$DRY_RUN" = true ]; then
    echo "[dry-run] code --install-extension $extension --force"
  else
    code --install-extension "$extension" --force
  fi
done < "$extension_file"
