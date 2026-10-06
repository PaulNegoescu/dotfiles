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

packages=(
  bat
  btop
  build-essential
  ca-certificates
  curl
  eza
  fd-find
  fzf
  gh
  git
  git-delta
  gitleaks
  glow
  jq
  less
  locales
  nano
  podman
  podman-compose
  python3
  python3-pip
  ripgrep
  shellcheck
  trash-cli
  unzip
  webp
  zoxide
  zsh
  zsh-autosuggestions
  zsh-syntax-highlighting
)

if [ "$DRY_RUN" = true ]; then
  echo "[dry-run] sudo apt-get update"
  printf '[dry-run] sudo apt-get install --yes'
  printf ' %q' "${packages[@]}"
  echo
  echo "[dry-run] install Starship from starship.rs"
  echo "[dry-run] install Hunk from hunk.dev"
  echo "[dry-run] create compatibility links for bat, fd, and trash-cli when needed"
  exit
fi

sudo apt-get update

available=()
missing=()
for package in "${packages[@]}"; do
  if apt-cache show "$package" > /dev/null 2>&1; then
    available+=("$package")
  else
    missing+=("$package")
  fi
done

sudo apt-get install --yes "${available[@]}"

if ((${#missing[@]})); then
  printf 'Warning: these packages are not available from this Ubuntu release: %s\n' "${missing[*]}" >&2
fi

mkdir -p "$HOME/.local/bin"

if ! command -v bat > /dev/null 2>&1 && command -v batcat > /dev/null 2>&1; then
  ln -sfn "$(command -v batcat)" "$HOME/.local/bin/bat"
fi

if ! command -v fd > /dev/null 2>&1 && command -v fdfind > /dev/null 2>&1; then
  ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

if ! command -v trash > /dev/null 2>&1 && command -v trash-put > /dev/null 2>&1; then
  ln -sfn "$(command -v trash-put)" "$HOME/.local/bin/trash"
fi

if ! locale -a | grep -qi '^en_US\.utf8$'; then
  sudo locale-gen en_US.UTF-8
fi

if ! command -v starship > /dev/null 2>&1; then
  curl -fsSL https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$HOME/.local/bin"
fi

if ! command -v hunk > /dev/null 2>&1; then
  curl -fsSL https://hunk.dev/install.sh | sh
fi

if ! command -v tldr > /dev/null 2>&1; then
  case "$(uname -m)" in
    x86_64) tlrc_target="x86_64-unknown-linux-gnu" ;;
    aarch64 | arm64) tlrc_target="aarch64-unknown-linux-gnu" ;;
    *)
      echo "Warning: no prebuilt tlrc binary is configured for $(uname -m)." >&2
      tlrc_target=""
      ;;
  esac

  if [ -n "$tlrc_target" ]; then
    tlrc_release=$(curl -fsSL https://api.github.com/repos/tldr-pages/tlrc/releases/latest)
    tlrc_url=$(printf '%s' "$tlrc_release" \
      | jq -r --arg suffix "-$tlrc_target.tar.gz" \
        '.assets[] | select(.name | endswith($suffix)) | .browser_download_url' \
      | head -n 1)
    tlrc_digest=$(printf '%s' "$tlrc_release" \
      | jq -r --arg suffix "-$tlrc_target.tar.gz" \
        '.assets[] | select(.name | endswith($suffix)) | (.digest // "")' \
      | head -n 1)

    if [ -z "$tlrc_url" ]; then
      echo "Could not find a tlrc release for $tlrc_target." >&2
      exit 1
    fi

    tlrc_temp=$(mktemp -d)
    curl -fsSL "$tlrc_url" -o "$tlrc_temp/tlrc.tar.gz"

    if [[ "$tlrc_digest" == sha256:* ]]; then
      printf '%s  %s\n' "${tlrc_digest#sha256:}" "$tlrc_temp/tlrc.tar.gz" | sha256sum --check -
    fi

    tar -xzf "$tlrc_temp/tlrc.tar.gz" -C "$tlrc_temp"
    install -m 0755 "$(find "$tlrc_temp" -type f -name tldr -print -quit)" "$HOME/.local/bin/tldr"
    rm -rf "$tlrc_temp"
  fi
fi

echo "WSL command-line tools are installed."
