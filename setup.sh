#!/bin/bash
#
# Set up computer environment
#
# Author: Nick Plekhanov, https://plekhanov.me
# License: MIT
# https://github.com/nicksp/dotfiles

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
light_red=$(tput setaf 9)
bold=$(tput bold)
reset=$(tput sgr0)

title() {
  echo "${bold}==> $1${reset}"
  echo
}

warning() {
  tput setaf 1
  echo "/!\\ $1 /!\\"
  tput sgr0
}

command_exists() {
  command -v "$@" &> /dev/null
}

echo -e "
${yellow}
          _ ._  _ , _ ._
        (_ ' ( \`  )_  .__)
      ( (  (    )   \`)  ) _)
     (__ (_   (_ . _) _) ,__)
           ~~\ ' . /~~
         ,::: ;   ; :::,
        ':::::::::::::::'
 ____________/_ __ \____________
|                               |
|  Welcome to Paul's dotfiles   |
|_______________________________|
"
echo
echo -e "${yellow}!!! ${red}WARNING${yellow} !!!"
echo -e "${light_red}This script will delete all your configuration files!"
echo -e "${light_red}Use it at your own risk."

if [ $# -ne 1 ] || [ "$1" != "-y" ]; then
  echo -e "${yellow}Press Enter key to continue…${reset}\n"
  read key
fi

# Use Touch ID to authorize sudo
if [ ! -f /etc/pam.d/sudo_local ]; then
  title "🔒 Enabling Touch ID to authorize sudo commands…"
  echo "auth       sufficient     pam_tid.so" | sudo tee /etc/pam.d/sudo_local
fi

# Ask for the administrator password upfront
warning "Activate sudo"
sudo echo "Sudo activated!"
echo

# Install Homebrew and packages/apps
title "🫖 Setting up Homebrew…"
"$DOTFILES_DIR/setup/brew.sh"
echo

# Setup Zsh and register it as a default shell
title "🐚 Setting up Zsh…"
"$DOTFILES_DIR/setup/zsh.sh"
echo

# Install Xcode, GitHub CLI & Node.js packages etc.
title "🚀 Setting up extra tools…"
"$DOTFILES_DIR/setup/misc.sh"
echo

# Install dotfiles symlinks
title "🍤 Setting up symlinks…"
DOTFILES_DIR="$DOTFILES_DIR" "$DOTFILES_DIR/setup/symlinks.sh"

echo
echo "🦏 ${green}All done! Open a new terminal for the changes to take effect or run: source ~/.zshrc.${reset}"

"$DOTFILES_DIR/bin/nyan"
