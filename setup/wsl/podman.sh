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

machine_name="podman-machine-default"
socket_directory="/mnt/wsl/podman-sockets/$machine_name"
connection_name="$machine_name-root"
socket_path="$socket_directory/podman-root.sock"
dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
membership_changed=false

if [ ! -S "$socket_path" ]; then
  connection_name="$machine_name-user"
  socket_path="$socket_directory/podman-user.sock"
fi

if [ "$DRY_RUN" = true ]; then
  echo "[dry-run] connect Podman to unix://$socket_path"
  echo "[dry-run] add the current WSL user to the socket's group if required"
  echo "[dry-run] verify docker and docker compose compatibility"
  exit
fi

if ! command -v podman > /dev/null 2>&1; then
  echo "Podman client is unavailable. Run the WSL packages step first." >&2
  exit 1
fi

if [ ! -S "$socket_path" ]; then
  cat >&2 << EOF
No Podman Desktop socket was found under $socket_directory.
Start Podman Desktop and its default machine on Windows, then retry this step.
EOF
  exit 1
fi

socket_gid=$(stat -c '%g' "$socket_path")
if ! id -G | tr ' ' '\n' | grep -qx "$socket_gid"; then
  socket_group=$(getent group "$socket_gid" | cut -d: -f1)
  if [ -z "$socket_group" ]; then
    socket_group="podman-desktop"
    sudo groupadd --gid "$socket_gid" "$socket_group"
  fi
  sudo usermod --append --groups "$socket_group" "$USER"
  membership_changed=true
  echo "Added $USER to group $socket_group ($socket_gid). Run 'wsl --shutdown' in PowerShell after setup."
fi

if podman system connection list --format '{{.Name}}' | grep -qx "$connection_name"; then
  podman system connection default "$connection_name"
else
  podman system connection add --default "$connection_name" "unix://$socket_path"
fi

export CONTAINER_HOST="unix://$socket_path"

if [ "$membership_changed" = true ]; then
  echo "Podman connection saved. Restart WSL before testing access to the shared socket."
  exit
fi

podman version

if [ -x "$dotfiles_dir/bin/docker" ]; then
  "$dotfiles_dir/bin/docker" version
  if command -v podman-compose > /dev/null 2>&1; then
    "$dotfiles_dir/bin/docker" compose version
  else
    echo "Warning: no Compose provider is installed; rerun the WSL packages step." >&2
  fi
fi

echo "WSL now uses the Podman Desktop engine through Docker-compatible commands."
