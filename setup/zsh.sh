#!/bin/bash

# Note: Zsh is now the default shell for all newly created user accounts,
# starting with macOS Catalina: https://support.apple.com/en-us/102360
#
# Installs up-to-date zsh and registers it as the default shell
# https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH

set -euo pipefail

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

bold=""
reset=""

if [ -t 1 ] && command -v tput > /dev/null 2>&1; then
  bold=$(tput bold || true)
  reset=$(tput sgr0 || true)
fi

title() {
  echo "${bold}==> $1${reset}"
  echo
}

zsh_path="$(brew --prefix)/bin/zsh"

if [ ! -x "$zsh_path" ]; then
  echo "Homebrew Zsh is required. Install the Homebrew bundle first." >&2
  exit 1
fi

# We're all good already
if [ "$SHELL" == "$zsh_path" ]; then
  echo "Nothing to update. You're already using Zsh as your default shell 👏"
  exit 0
fi

# To work around an error for non-standard shell,
# ensure zsh is a valid shell option
if ! grep -Fxq "$zsh_path" /etc/shells; then
  title "Adding Zsh to list of allowed shells..."
  printf '%s\n' "$zsh_path" | sudo tee -a /etc/shells > /dev/null
  echo
fi

# Set the default shell to ZSH
title "Changing your shell to ${zsh_path}…"
chsh -s "$zsh_path"
echo "Your shell has been changed to zsh, please restart your terminal or tab"
echo
