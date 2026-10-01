#!/bin/bash

set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  echo "Podman setup currently supports macOS only." >&2
  exit 1
fi

if ! command -v podman > /dev/null; then
  echo "Podman is required. Install the Homebrew bundle first." >&2
  exit 1
fi

if ! podman machine inspect > /dev/null 2>&1; then
  echo "Initializing the default Podman machine..."
  podman machine init
fi

machine_state="$(podman machine inspect --format '{{.State}}')"

if [ "$machine_state" != "running" ]; then
  echo "Starting the default Podman machine..."
  podman machine start --update-connection=true
fi

socket_target="$(readlink /var/run/docker.sock 2> /dev/null || true)"

if [[ "$socket_target" != *podman* ]]; then
  if ! command -v podman-mac-helper > /dev/null; then
    echo "podman-mac-helper is required for Docker socket compatibility." >&2
    exit 1
  fi

  echo "Administrator access is required to map /var/run/docker.sock to Podman."
  sudo "$(command -v podman-mac-helper)" install

  podman machine stop
  podman machine start --update-connection=true
fi

podman info > /dev/null

echo
echo "Podman is running. Open a new terminal to use docker and docker compose."
