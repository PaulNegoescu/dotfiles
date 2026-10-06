# Paul's Dotfiles 🌮

My personal dotfiles for configuring macOS and Windows 11 with a shared Zsh development environment.

> [!WARNING] I recommend forking this repository to create your own set of dotfiles.

## Platforms

- macOS uses Homebrew, Ghostty, and native Podman.
- Windows 11 uses WinGet, WezTerm, VS Code, Podman Desktop, and Ubuntu 26.04 under WSL 2.
- Both platforms share Zsh, Starship, Git, Node.js, pnpm, Hunk, Delta, eza, fzf, and the rest of the tracked CLI configuration.

Administrator access and an internet connection are required during setup.

## What's in there?

- Handy [CLI scripts](bin/).
- Coding agents [config automation](agents/).
- [Custom zsh theme](tilde/.starship.toml) with Git status, etc. using [Starship](https://starship.rs/).
- [Git aliases](tilde/.gitconfig).
- [Zsh aliases](zsh/aliases.zsh).
- zsh / [fzf](zsh/fzf.zsh).
- git / hunk terminal diff viewer.
- Sensible [macOS defaults](setup/macos.sh).
- A guided [Windows and WSL setup](docs/windows.md).
- [Visual Studio Code settings synchronization](vscode/).
- Config for other apps and utils.
- [macOS apps and VSCode extensions](setup/Brewfile) I use.
- [macOS tips & tricks](/docs/macos%20tips%20&%20tricks.md).

## macOS installation

1. Configure GitHub SSH
   1. [Generate SSH key and add it to the ssh-agent](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
   1. [Add your public SSH key to GitHub account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
   1. Test your authentication with:

      ```bash
      ssh -T git@github.com
      ```

1. Install [MonoLisa font](https://www.monolisa.dev/)
1. Clone the repository:

```bash
mkdir -p ~/work/personal
git clone git@github.com:PaulNegoescu/dotfiles.git ~/work/personal/dotfiles
cd ~/work/personal/dotfiles
```

### Interactive setup wizard

Run the setup wizard:

```bash
./setup.sh
```

Every machine-changing step requires separate approval and defaults to **No**:

- Touch ID for `sudo`
- Xcode Command Line Tools
- Homebrew packages, applications, fonts, and VS Code extensions
- Podman VM and Docker-compatible commands
- Homebrew Zsh as the default shell
- Node.js LTS, Corepack, and pnpm
- Dotfile and editor-setting symlinks
- macOS preferences, with a dry-run preview before applying

To deliberately run every step without confirmation:

```bash
./setup.sh --yes
```

The symlink step creates `~/.dotfiles` as a stable link to the repository. Shell configuration uses that stable path regardless of where the repository is cloned.

## Windows 11 installation

Open PowerShell in a checkout of this repository and run (the wizard installs PowerShell 7 as part of the core profile):

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./setup.ps1
```

The Windows wizard asks separately before installing:

- core applications with WinGet: PowerShell, Git, VS Code, WezTerm, 7-Zip, Bulk Crap Uninstaller, Raycast, Podman, and Podman Desktop;
- optional personal applications;
- MesloLGS Nerd Font Mono;
- WSL 2 with Ubuntu 26.04 LTS;
- WezTerm and VS Code configuration;
- native VS Code extensions;
- the Podman machine;
- the Linux development environment inside WSL.

Every step defaults to **No**. Preview selected actions without changing the machine with:

```powershell
./setup.ps1 -DryRun
```

See the [Windows setup guide](docs/windows.md) for the two-layer architecture, restart points, MonoLisa installation, Podman integration, and individual commands.

### Containers

Podman is the container engine. The setup keeps Docker-compatible command names:

- `docker` delegates to the Podman CLI.
- `docker compose` uses Podman's Compose provider.
- `/var/run/docker.sock` maps to the Podman machine so Docker-aware tools can use the same engine.

On macOS, the setup initializes the native Podman machine and maps its compatible socket. On Windows, Podman Desktop owns one Podman machine and the Ubuntu client connects to its shared WSL socket. The tracked `docker` shim delegates to Podman on both platforms.

`podman compose` is included in the Podman CLI, but it delegates to an external Compose provider. The setup therefore retains `podman-compose`; no Docker engine is installed.

### Individual setup steps

Each component can also be run independently:

```bash
./setup/xcode.sh
./setup/brew.sh
./setup/podman.sh
./setup/zsh.sh
./setup/misc.sh
./setup/symlinks.sh --dry-run
./setup/symlinks.sh
./setup/macos.sh --dry-run
./setup/macos.sh
```

## Validation

Install the repository dependencies and run all formatting and shell checks:

```bash
pnpm install --frozen-lockfile
pnpm check
```

The same validation runs automatically for pull requests and pushes to `main`.

## Extras

### Set macOS defaults

```bash
set-defaults
```

## Local customizations

The dotfiles can be extended to suit additional local requirements by using the following files:

### `~/.zsh.local`

If this file exists, it will be automatically sourced after all the other shell related files allowing its content to add to or overwrite the existing aliases, settings, PATH, etc.

### `~/.ssh/config.local`

If this file exists, it will be automatically included after the public SSH hosts to specify any additional SSH hosts.

### `~/.gitconfig.local`

If this file exists, it will be automatically included after the configurations from `~/.gitconfig` allowing its content to overwrite or add to the existing `git` configurations.

> [!TIP] Use `~/.gitconfig.local` to store sensitive information such as the `git` user credentials for individual repositories.

## Updating

```bash
cd ~/work/personal/dotfiles
git pull --ff-only
./setup.sh
```

On Windows, pull from inside the WSL checkout and rerun the relevant wizard:

```bash
cd ~/work/personal/dotfiles
git pull --ff-only
./setup/wsl/setup.sh
```

## License

MIT License.

## Attribution

Originally forked from [nicksp/dotfiles](https://github.com/nicksp/dotfiles), licensed under the MIT License.

- [Catppuccin for eza](https://github.com/catppuccin/eza), licensed under the MIT License.

## Inspiration

- [holman/dotfiles](https://github.com/holman/dotfiles)
- [mathiasbynes/dotfiles](https://github.com/mathiasbynens/dotfiles)
- [sapegin/dotfiles](https://github.com/sapegin/dotfiles)
- <https://remysharp.com/2018/08/23/cli-improved>
- <https://evanhahn.com/a-decade-of-dotfiles/>
- <https://cpojer.net/posts/set-up-a-new-mac-fast>
- <https://thevaluable.dev/zsh-install-configure-mouseless/>
