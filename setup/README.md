# Setup Scripts

Run `../setup.sh` on macOS or `../setup.ps1` on Windows for an interactive wizard that asks before executing every machine-changing step. All prompts default to **No**.

The `windows/` scripts configure native Windows applications. The `wsl/` scripts configure Ubuntu, keeping Windows application management separate from the Linux development environment.

## xcode

Installs the Xcode Command Line Tools required by Homebrew.

## brew

Installs Homebrew, packages, applications and VSCode extensions using [Brewfile](./Brewfile).

## macos

Applies the selected macOS defaults. Run with `--dry-run` to preview every command without changing preferences. Based on [~/.macos](https://mths.be/macos) by @mathiasbynens.

## misc

Installs the current Node.js LTS release through `fnm`, configures Corepack and pnpm, applies npm defaults, checks GitHub CLI authentication, and makes the repository helper scripts executable.

## symlinks

Creates symlinks to dotfiles by placing them in the home directory. Run with `--dry-run` to preview every action without changing files.

## zsh

Installs Zsh and registers Zsh as the default shell.

## Windows

`windows/packages.ps1` installs native applications with exact WinGet identifiers. `windows/fonts.ps1` installs MesloLGS Nerd Font Mono for the current user. `windows/config.ps1` safely copies WezTerm and VS Code configuration, backing up different existing files. `windows/wsl.ps1` installs Ubuntu 26.04, and `windows/podman.ps1` initializes the Podman machine.

Each script accepts `-DryRun`. Package profiles can be run independently:

```powershell
./setup/windows/packages.ps1 -Profile Core -DryRun
./setup/windows/packages.ps1 -Profile Apps -DryRun
```

## WSL

`wsl/setup.sh` is the interactive Ubuntu wizard. It installs the Linux CLI toolchain, current Node.js LTS, latest pnpm, shared dotfile links, private Git identity, Podman Desktop socket connection, remote VS Code extensions, and Zsh as the default shell.

```bash
./setup/wsl/setup.sh --dry-run
./setup/wsl/setup.sh
```
