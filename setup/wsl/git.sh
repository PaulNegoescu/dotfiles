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

local_config="$HOME/.gitconfig.local"

if [ -f "$local_config" ] \
  && git config --file "$local_config" user.name > /dev/null \
  && git config --file "$local_config" user.email > /dev/null; then
  echo "Git identity is already configured in $local_config."
  exit
fi

if [ "$DRY_RUN" = true ]; then
  echo "[dry-run] prompt for Git name and email, then save them to $local_config"
  exit
fi

default_name=${GIT_USER_NAME:-Paul Negoescu}
git_name=${GIT_USER_NAME:-}
git_email=${GIT_USER_EMAIL:-}

if [ -z "$git_name" ]; then
  printf 'Git user name [%s]: ' "$default_name"
  read -r git_name
  git_name=${git_name:-$default_name}
fi

if [ -z "$git_email" ]; then
  printf 'Git user email: '
  read -r git_email
fi

if [ -z "$git_email" ]; then
  echo "Git email cannot be empty." >&2
  exit 1
fi

umask 077
git config --file "$local_config" user.name "$git_name"
git config --file "$local_config" user.email "$git_email"

echo "Git identity saved to $local_config."
