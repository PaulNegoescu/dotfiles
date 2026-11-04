#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ASSUME_YES=false
DRY_RUN=false

usage() {
  cat << 'EOF'
Usage: ./setup/wsl/setup.sh [--yes] [--dry-run]

Configure the Ubuntu WSL development environment. Every step defaults to No
and can be selected independently.

Options:
  -y, --yes      Run every setup step without confirmation
      --dry-run  Show the selected actions without changing the machine
  -h, --help     Show this help message
EOF
}

while (($#)); do
  case "$1" in
    -y | --yes) ASSUME_YES=true ;;
    --dry-run) DRY_RUN=true ;;
    -h | --help)
      usage
      exit
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if ! grep -qi microsoft /proc/version 2> /dev/null; then
  echo "This setup wizard must run inside WSL." >&2
  exit 1
fi

confirm() {
  local answer
  if [ "$ASSUME_YES" = true ]; then
    printf '%s [yes]\n' "$1"
    return 0
  fi

  printf '%s [y/N] ' "$1"
  read -r answer
  [[ "$answer" =~ ^([yY]|[yY][eE][sS])$ ]]
}

run_step() {
  local prompt=$1 heading=$2
  shift 2

  if confirm "$prompt"; then
    printf '\n==> %s\n\n' "$heading"
    "$@"
  else
    printf 'Skipped: %s\n' "$heading"
  fi
}

dry_run_args=()
if [ "$DRY_RUN" = true ]; then
  dry_run_args+=(--dry-run)
  echo "Dry-run mode is active."
fi

echo "Welcome to Paul's Ubuntu WSL setup"
echo "Each step is optional and defaults to No."

case "$DOTFILES_DIR" in
  /mnt/*)
    echo
    echo "Note: this repository is on a Windows-mounted drive ($DOTFILES_DIR)."
    echo "For faster Git and Node operations, clone it under ~/work inside WSL later."
    ;;
esac

run_step \
  "Install or update Ubuntu command-line packages, Starship, and Hunk?" \
  "Install WSL command-line tools" \
  "$DOTFILES_DIR/setup/wsl/packages.sh" "${dry_run_args[@]}"

run_step \
  "Install the current Node.js LTS release and the latest pnpm?" \
  "Configure Node.js and pnpm" \
  "$DOTFILES_DIR/setup/wsl/node.sh" "${dry_run_args[@]}"

run_step \
  "Link the shared shell, Git, SSH, and tool configuration into your WSL home?" \
  "Link WSL dotfiles" \
  env DOTFILES_DIR="$DOTFILES_DIR" "$DOTFILES_DIR/setup/wsl/symlinks.sh" "${dry_run_args[@]}"

run_step \
  "Configure your private Git name and email for WSL?" \
  "Configure Git identity" \
  "$DOTFILES_DIR/setup/wsl/git.sh" "${dry_run_args[@]}"

run_step \
  "Connect the WSL Podman client to Podman Desktop and enable Docker-compatible commands?" \
  "Configure Podman in WSL" \
  "$DOTFILES_DIR/setup/wsl/podman.sh" "${dry_run_args[@]}"

run_step \
  "Install development extensions in the VS Code WSL extension host?" \
  "Install VS Code WSL extensions" \
  "$DOTFILES_DIR/setup/wsl/vscode.sh" "${dry_run_args[@]}"

if command -v zsh > /dev/null 2>&1 && [ "${SHELL:-}" != "$(command -v zsh)" ]; then
  if confirm "Make Zsh your default WSL shell?"; then
    if [ "$DRY_RUN" = true ]; then
      echo "[dry-run] chsh -s $(command -v zsh)"
    else
      chsh -s "$(command -v zsh)"
    fi
  else
    echo "Skipped: Make Zsh the default shell"
  fi
fi

echo
echo "WSL setup wizard finished. Open a new WezTerm window to load shell changes."
