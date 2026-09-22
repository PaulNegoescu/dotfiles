#!/bin/bash
#
# Interactive setup wizard for this dotfiles repository.
#
# Author: Nick Plekhanov, https://plekhanov.me
# License: MIT
# https://github.com/nicksp/dotfiles

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSUME_YES=false

usage() {
  cat << 'EOF'
Usage: ./setup.sh [--yes]

Run the interactive setup wizard. Every step defaults to "No" and can be
selected independently.

Options:
  -y, --yes  Run every setup step without confirmation
  -h, --help Show this help message
EOF
}

for argument in "$@"; do
  case "$argument" in
    -y | --yes)
      ASSUME_YES=true
      ;;
    -h | --help)
      usage
      exit
      ;;
    *)
      echo "Unknown option: $argument" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [ "$(uname -s)" != "Darwin" ]; then
  echo "This setup wizard only supports macOS." >&2
  exit 1
fi

bold=""
green=""
yellow=""
reset=""

if [ -t 1 ] && command -v tput > /dev/null 2>&1; then
  bold=$(tput bold || true)
  green=$(tput setaf 2 || true)
  yellow=$(tput setaf 3 || true)
  reset=$(tput sgr0 || true)
fi

title() {
  printf '\n%s==> %s%s\n\n' "$bold" "$1" "$reset"
}

skipped() {
  printf '%sSkipped:%s %s\n' "$yellow" "$reset" "$1"
}

confirm() {
  local answer

  if [ "$ASSUME_YES" = true ]; then
    printf '%s [yes]\n' "$1"
    return 0
  fi

  printf '%s [y/N] ' "$1"
  read -r answer

  case "$answer" in
    y | Y | yes | Yes | YES) return 0 ;;
    *) return 1 ;;
  esac
}

load_homebrew() {
  if command -v brew > /dev/null; then
    eval "$(brew shellenv)"
  elif [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

run_step() {
  local prompt=$1
  local heading=$2
  shift 2

  if confirm "$prompt"; then
    title "$heading"
    "$@"
  else
    skipped "$heading"
  fi
}

enable_touch_id() {
  if grep -q 'pam_tid\.so' /etc/pam.d/sudo_local 2> /dev/null; then
    echo "Touch ID for sudo is already configured."
    return
  fi

  if [ -f /etc/pam.d/sudo_local.template ]; then
    sed -E 's/^#(auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so.*)$/\1/' \
      /etc/pam.d/sudo_local.template \
      | sudo tee /etc/pam.d/sudo_local > /dev/null
  else
    printf '%s\n' 'auth       sufficient     pam_tid.so' \
      | sudo tee /etc/pam.d/sudo_local > /dev/null
  fi

  echo "Touch ID for sudo has been enabled."
}

printf '%b\n' "${yellow}"
cat <<'EOS'
         oooooooooooooooooooooooooooooooooooooooooooooo
   ooo$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ooo
  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
 o$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$o
 $$$$$   $$$" "$$$$$" "$     $     $  "$ $$$$$"    "$ "$  $$$
 $$$$" "$$  $$oo$$$$$  $$oo$  $$$$  $$$$   " $$$$$ $$ $ "  $$$
o$$$$  $  $$o    "$$$$$o "$    $$     $      $$$$$  $$  $      $$$o
$$$$   o   $""$$  $$$$$""$$  $  $$$$  $$$$  o   $$$$$  $$  $  o   $$$$
$$$$  $$$  $o    o$$$$$o    o$     $     $  $o  $$$$$o    o$  $o  $$$$
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$"""""""""""""""""""""""""""""""""""""$$$$$$$$$$$$""""""""""""""""""$$$$
$$$$                                      "$$$$$$$$$$"           o$$$$
$$$$                                       "$$$$$$$$"           o$$$$$
$$$$                                        $$$$$$$$            $$$$$$
$$$$$$$$$$$$$           $$$$$$$$$            $$$$$$            $$$$$$$
$$$$$$$$$$$$$           $$$$$$$$$$            $$$$            $$$$$$$$
$$$$$$$$$$$$$           $$$$$$$$$$$           "$$"           $$$$$$$$$
$$$$$$$$$$$$$           $$$$$$$$$$$o           ""           o$$$$$$$$$
$$$$$$$$$$$$$           $$$$$$$$$$$$o                      o$$$$$$$$$$
$$$$$$$$$$$$$           $$$$$$$$$$$$$o                    o$$$$$$$$$$$
$$$$$$$$$$$$$           $$$$$$$$$$$$$$o                  o$$$$$$$$$$$$
"$$$$$$$$$$$$ $$$$$$$$$$$$$$$ $$$$$$$$$$$$"
 $$$$$$$$$$$$           $$$$$$$$$$$$$$$$                $$$$$$$$$$$$$
 $$$$$$$$$$$$           $$$$$$$$$$$$$$$$$              $$$$$$$$$$$$$$
 "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
   """$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"""
            """"""""""""""""""""""""""""""""""""""""
 ____________/_ __ \____________
|                               |
|  Welcome to Paul's dotfiles   |
|_______________________________|
EOS
printf '%b\n' "${reset}"

echo "Each step is optional. Existing files are preserved unless you explicitly"
echo "choose to replace them during the symlink step."

if ! grep -q 'pam_tid\.so' /etc/pam.d/sudo_local 2> /dev/null; then
  run_step \
    "Enable Touch ID for sudo commands?" \
    "Enable Touch ID for sudo" \
    enable_touch_id
fi

if xcode-select -p > /dev/null 2>&1; then
  echo "Xcode Command Line Tools are already installed."
else
  run_step \
    "Install Xcode Command Line Tools?" \
    "Install Xcode Command Line Tools" \
    "$DOTFILES_DIR/setup/xcode.sh"
fi

if xcode-select -p > /dev/null 2>&1; then
  run_step \
    "Install or update Homebrew packages, apps, fonts, and VS Code extensions?" \
    "Install Homebrew software" \
    "$DOTFILES_DIR/setup/brew.sh"
else
  skipped "Install Homebrew software (Xcode Command Line Tools are unavailable)"
fi

load_homebrew

if command -v brew > /dev/null; then
  run_step \
    "Configure Homebrew Zsh as your default shell?" \
    "Configure Zsh" \
    "$DOTFILES_DIR/setup/zsh.sh"

  run_step \
    "Install and configure Node.js LTS, Corepack, and pnpm?" \
    "Configure developer tooling" \
    "$DOTFILES_DIR/setup/misc.sh"
else
  skipped "Configure Zsh (Homebrew is unavailable)"
  skipped "Configure developer tooling (Homebrew is unavailable)"
fi

run_step \
  "Link dotfiles and editor settings into your home directory?" \
  "Link dotfiles" \
  env DOTFILES_DIR="$DOTFILES_DIR" "$DOTFILES_DIR/setup/symlinks.sh"

if confirm "Preview the macOS settings managed by this repository?"; then
  title "Preview macOS settings"
  "$DOTFILES_DIR/setup/macos.sh" --dry-run

  if confirm "Apply these macOS settings now?"; then
    title "Apply macOS settings"
    "$DOTFILES_DIR/setup/macos.sh"
  else
    skipped "Apply macOS settings"
  fi
else
  skipped "Preview and apply macOS settings"
fi

echo
echo "${green}Setup wizard finished.${reset} Open a new terminal to load shell changes."
