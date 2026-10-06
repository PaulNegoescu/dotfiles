# Windows 11 Setup

The Windows setup deliberately has two layers:

- **Windows host:** WinGet applications, WezTerm, VS Code, fonts, Raycast, and Podman Desktop.
- **Ubuntu 26.04 on WSL 2:** Zsh, Starship, Git tooling, Node.js, pnpm, Hunk, Delta, and project checkouts.

This keeps the Unix development workflow close to macOS without maintaining a second shell configuration for Git Bash or PowerShell. No tmux, alternative file manager, or Docker Desktop is installed.

## First installation

1. Install all pending Windows updates.
1. Install Git, then clone this repository. A temporary Windows checkout is enough to start the host setup:

   ```powershell
   winget install --id Git.Git --exact
   git clone https://github.com/PaulNegoescu/dotfiles.git $HOME\work\personal\dotfiles
   cd $HOME\work\personal\dotfiles
   ```
1. Open PowerShell 7 in the checkout and run:

   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   ./setup.ps1
   ```

1. Approve only the steps you want. Each answer defaults to **No**.
1. Restart Windows if the WSL installer requests it.
1. Launch **Ubuntu 26.04** once and create the Linux username and password.
1. Create a separate SSH key inside WSL and add its public key to GitHub:

   ```bash
   ssh-keygen -t ed25519 -C "your-email@example.com"
   cat ~/.ssh/id_ed25519.pub | clip.exe
   ssh -T git@github.com
   ```

1. For best Git and Node performance, clone the repository onto the WSL filesystem:

   ```bash
   mkdir -p ~/work/personal
   git clone git@github.com:PaulNegoescu/dotfiles.git ~/work/personal/dotfiles
   cd ~/work/personal/dotfiles
   ./setup/wsl/setup.sh
   ```

The WSL wizard still works from a repository under `/mnt/c`, but large Git repositories and `node_modules` should live in the Linux filesystem.

## Terminals and editor

WezTerm opens `Ubuntu-26.04` by default and uses a Panda-inspired palette. Its font fallback is:

1. MonoLisa, when the separately licensed font is installed manually on Windows.
1. MesloLGS Nerd Font Mono, installed by the setup wizard.

VS Code remains a native Windows application. Open projects with **WSL: Connect to WSL** so terminals, language servers, Git, Node, and pnpm run inside Ubuntu. The repository installs UI extensions on Windows and development extensions into the WSL extension host.

## Containers

Podman Desktop owns the single Podman machine. The WSL setup connects Ubuntu's Podman client to the socket exposed at `/mnt/wsl/podman-sockets/podman-machine-default/` and makes that connection the default.

The repository's `docker` command delegates to Podman, so these use the same engine:

```bash
podman ps
docker ps
docker compose up
```

Podman's `compose` subcommand is a wrapper around a Compose provider, so `podman-compose` is installed in Ubuntu. This does not install or run a Docker engine.

After the WSL user is added to the shared socket group, close terminals and run this once in PowerShell:

```powershell
wsl --shutdown
```

Then reopen WezTerm and test the three commands above. Bind mounts should use projects stored in the WSL filesystem; cross-distribution Podman Desktop mounts can have different path semantics from a native Linux engine.

## Git identity and authentication

The public `.gitconfig` includes `~/.gitconfig.local`. The WSL wizard can create that private file with your name and email; it is never stored in this repository. Authenticate the GitHub CLI separately when you want it:

```bash
gh auth login
```

## Individual steps

Preview any PowerShell step with `-DryRun`:

```powershell
./setup/windows/packages.ps1 -Profile Core -DryRun
./setup/windows/packages.ps1 -Profile Apps -DryRun
./setup/windows/fonts.ps1 -DryRun
./setup/windows/wsl.ps1 -DryRun
./setup/windows/config.ps1 -DryRun
./setup/windows/vscode.ps1 -DryRun
./setup/windows/podman.ps1 -DryRun
```

Preview the Ubuntu setup with:

```bash
./setup/wsl/setup.sh --dry-run
```

Rerunning the setup is safe: WinGet upgrades or leaves installed packages alone, links are skipped when current, different files receive timestamped backups, and application configuration is copied only after approval.

## Native applications

The optional WinGet profile mirrors cross-platform apps from the Brewfile where reliable Windows packages exist. It intentionally uses Windows Explorer, 7-Zip, Raycast, and Bulk Crap Uninstaller. macOS-only tools such as Ghostty, Marta, Keka, Hidden Bar, and AlDente are not installed.
