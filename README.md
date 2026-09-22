# Paul's Dotfiles 🌮

My personal dotfiles for configuring macOS with Zsh and Homebrew.

> [!WARNING] I recommend forking this repository to create your own set of dotfiles.

## Requirements

- macOS
- Administrator access
- An internet connection

## What's in there?

- Handy [CLI scripts](bin/).
- Coding agents [config automation](agents/).
- [Custom zsh theme](tilde/.starship.toml) with Git status, etc. using [Starship](https://starship.rs/).
- [Git aliases](tilde/.gitconfig).
- [Zsh aliases](zsh/aliases.zsh).
- zsh / [fzf](zsh/fzf.zsh).
- git / hunk terminal diff viewer.
- Sensible [macOS defaults](setup/macos.sh).
- [Visual Studio Code settings synchronization](vscode/).
- Config for other apps and utils.
- [macOS apps and VSCode extensions](setup/Brewfile) I use.
- [macOS tips & tricks](/docs/macos%20tips%20&%20tricks.md).

## Installation

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
- Homebrew Zsh as the default shell
- Node.js LTS, Corepack, and pnpm
- Dotfile and editor-setting symlinks
- macOS preferences, with a dry-run preview before applying

To deliberately run every step without confirmation:

```bash
./setup.sh --yes
```

The symlink step creates `~/.dotfiles` as a stable link to the repository. Shell configuration uses that stable path regardless of where the repository is cloned.

### Individual setup steps

Each component can also be run independently:

```bash
./setup/xcode.sh
./setup/brew.sh
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

## License

MIT License.

## Attribution

Originally forked from [nicksp/dotfiles](https://github.com/nicksp/dotfiles), licensed under the MIT License.

## Inspiration

- [holman/dotfiles](https://github.com/holman/dotfiles)
- [mathiasbynes/dotfiles](https://github.com/mathiasbynens/dotfiles)
- [sapegin/dotfiles](https://github.com/sapegin/dotfiles)
- <https://remysharp.com/2018/08/23/cli-improved>
- <https://evanhahn.com/a-decade-of-dotfiles/>
- <https://cpojer.net/posts/set-up-a-new-mac-fast>
- <https://thevaluable.dev/zsh-install-configure-mouseless/>
