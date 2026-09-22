#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v brew > /dev/null; then
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

if ! command -v brew > /dev/null; then
  echo "Homebrew is required. Run ./setup/brew.sh first." >&2
  exit 1
fi

eval "$(brew shellenv)"

DOTFILES_DIR="$(pwd)"

BLUE=""
BOLD=""
RESET=""

if [ -t 1 ] && command -v tput > /dev/null 2>&1; then
  BLUE=$(tput setaf 4 || true)
  BOLD=$(tput bold || true)
  RESET=$(tput sgr0 || true)
fi

indent() {
  sed 's/^/  /'
}

info() {
  echo
  echo "[ ${BLUE}..${RESET} ] $1" | indent
}

command_exists() {
  command -v "$@" &> /dev/null
}

# Make custom binary scripts executable
info 'Changing access permissions for binary scripts…'
find "$DOTFILES_DIR/bin" -type f -not -name '.DS_Store' -not -name 'README.md' -exec chmod +x {} \; -exec bash -c 'printf "\r\033[2K  [ \033[00;32m✔\033[0m ] set for %s\n" "${0##*/}"' {} \;
echo
echo 'Done!' | indent
echo

# GitHub CLI: Authenticate with your GitHub account if the user is not logged in
if command_exists gh && ! gh auth status &> /dev/null; then
  echo "[GitHub CLI] You are not logged into any GitHub hosts. To log in, run: ${BOLD}gh auth login${RESET}"
fi

# Install and activate the latest Node.js LTS release
if ! command_exists fnm; then
  echo "fnm is required. Install the Homebrew bundle first." >&2
  exit 1
fi

eval "$(fnm env --shell bash)"
fnm install --lts --use
fnm default "$(fnm current)"

# Corepack is no longer bundled with Node.js 25+
npm install --global corepack@latest
corepack enable

# Provide pnpm outside projects; projects can select an exact version
# through their packageManager field
corepack install --global pnpm@latest

# Node.js global config
info "🚀 Configuring Node.js tooling..."
# Less verbose output
npm config set loglevel warn
# Disable funding messages
npm config set fund false
# Install exact version of packages ("1.2.3" instead of "^1.2.3" or "~1.2.3"). Keeps pinning durable
npm config set save-exact true
# Do not allow installing packages from Git
npm config set allow-git none
# Do not allow installing packages from a file
# npm config set allow-file none
# Do not allow installing packages from remote dependencies (URLs instead of npm registry)
# npm config set allow-remote none
# Only install package versions published at least 7 days ago
npm config set min-release-age 7
