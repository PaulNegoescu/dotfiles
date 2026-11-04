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

if [ "$DRY_RUN" = true ]; then
  echo "[dry-run] install fnm into ~/.local/share/fnm"
  echo "[dry-run] fnm install --lts --use"
  echo "[dry-run] fnm default <current LTS version>"
  echo "[dry-run] npm install --global corepack@latest"
  echo "[dry-run] corepack enable && corepack install --global pnpm@latest"
  exit
fi

if ! command -v fnm > /dev/null 2>&1; then
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$HOME/.local/share/fnm" --skip-shell
fi

export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --shell bash)"

fnm install --lts --use
fnm default "$(fnm current)"
npm install --global corepack@latest
corepack enable
corepack install --global pnpm@latest

npm config set init-author-name "Paul Negoescu"
npm config set init-author-url "https://github.com/PaulNegoescu"
npm config set init-license "MIT"

echo "Node $(node --version), npm $(npm --version), and pnpm $(pnpm --version) are ready."
