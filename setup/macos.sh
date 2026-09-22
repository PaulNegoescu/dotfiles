#!/bin/bash

set -euo pipefail

DRY_RUN=false

case "${1:-}" in
  --dry-run)
    DRY_RUN=true
    ;;
  "") ;;
  *)
    echo "Usage: $0 [--dry-run]" >&2
    exit 1
    ;;
esac

if [ "$(uname -s)" != "Darwin" ]; then
  echo "macOS defaults can only be configured on macOS." >&2
  exit 1
fi

run() {
  if [ "$DRY_RUN" = true ]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

echo "Configuring macOS preferences…"

# Appearance
run defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# Language and region
run defaults write NSGlobalDomain AppleLocale -string "en_RO"
run defaults write NSGlobalDomain AppleLanguages -array "en-RO" "ro-RO"
run defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
run defaults write NSGlobalDomain AppleTemperatureUnit -string "Celsius"
run defaults write NSGlobalDomain AppleMetricUnits -bool true

# Keyboard
run defaults write NSGlobalDomain KeyRepeat -int 5
run defaults write NSGlobalDomain InitialKeyRepeat -int 25

# Trackpad: natural scrolling
run defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true

# Finder
run defaults write NSGlobalDomain AppleShowAllExtensions -bool true
run defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Dock
run defaults write com.apple.dock autohide -bool false
run defaults write com.apple.dock tilesize -int 40
run defaults write com.apple.dock show-recents -bool false
run defaults write com.apple.dock minimize-to-application -bool true

if [ "$DRY_RUN" = false ]; then
  killall Finder > /dev/null 2>&1 || true
  killall Dock > /dev/null 2>&1 || true
  echo "Done. Some preferences may require logging out to take effect."
else
  echo "Dry run complete; nothing was changed."
fi
