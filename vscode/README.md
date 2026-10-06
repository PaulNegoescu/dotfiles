# Visual Studio Code Customization

## Install command line helper

> [!NOTE]  
> This is already included with the setup script.

Run “Install 'code' command in PATH” from the command palette (View → Command Palette) to make Code available from the command line.

## Install extensions on macOS

```shell
brew bundle install --file setup/Brewfile
```

See [Brewfile](../setup/Brewfile) for a list of extensions.

## Install extensions on Windows and WSL

The Windows wizard installs UI and integration extensions into native VS Code. The WSL wizard installs language and development extensions into the Ubuntu extension host:

```powershell
./setup/windows/vscode.ps1
```

```bash
./setup/wsl/vscode.sh
```

The split keeps WSL-specific language servers close to the project files while themes and Windows integration stay in the native application.

Windows receives the shared settings and keybindings plus [Windows-specific tasks](windows/tasks.json). macOS retains the tasks in `User/tasks.json`.
