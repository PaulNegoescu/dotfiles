#!/bin/bash

set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  echo "Xcode Command Line Tools can only be installed on macOS." >&2
  exit 1
fi

if xcode-select -p > /dev/null 2>&1; then
  echo "Xcode Command Line Tools are already installed at $(xcode-select -p)."
  exit
fi

echo "Opening the Xcode Command Line Tools installer…"
xcode-select --install 2> /dev/null || true
echo "Complete the installation in the macOS dialog. Waiting for it to finish…"

until xcode-select -p > /dev/null 2>&1; do
  sleep 5
done

echo "Xcode Command Line Tools installed at $(xcode-select -p)."
