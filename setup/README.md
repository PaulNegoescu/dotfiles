# Setup Scripts

Run `../setup.sh` for an interactive wizard that asks before executing every machine-changing step. All prompts default to **No**. Pass `--yes` only when you intentionally want to execute every step without confirmation.

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
