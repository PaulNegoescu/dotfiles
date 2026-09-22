#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")/.."

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

indent() {
  sed 's/^/  /'
}

# Homebrew requires Xcode Command Line Tools on supported macOS installations.
if ! xcode-select -p > /dev/null 2>&1; then
  echo "Xcode Command Line Tools are required. Run ./setup/xcode.sh first." >&2
  exit 1
fi

# Check for Homebrew and install it if required
if ! command -v brew &> /dev/null; then
  title "Installing Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if command -v brew > /dev/null; then
  eval "$(brew shellenv)"
elif [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
else
  echo "Homebrew installation completed but brew could not be found." >&2
  exit 1
fi

# Make sure we’re working with the latest version of Homebrew and its formulae
brew update

# Install fonts, tools, apps & vscode extensions
title "Installing software…"
brew bundle --file="$(pwd)/setup/Brewfile" | indent

# Extra apps
echo ""
title "☕️ Install more apps if you need them:"
echo "brew install --cask daisydisk"
echo "brew install --cask dbngin"
echo "brew install --cask figma"
echo "brew install --cask ibkr"
echo "brew install --cask zoom"
echo "brew install --cask adobe-creative-cloud"
echo "brew install --cask qobuz"

echo "${bold}Contrast${reset} − https://github.com/soffes/contrast"
echo "${bold}Audirvāna Origin${reset} − https://audirvana.com/audirvana-origin/"

# App Store apps
echo ""
title "🍏 Install additional apps from App Store:"
echo "https://apps.apple.com/us/app/adguard-ad-blocker-for-safari/id1440147259?mt=12"
echo "https://apps.apple.com/us/app/photomator-photo-editor/id1444636541"
echo "https://apps.apple.com/us/app/klack/id6446206067?mt=12"
echo ""
