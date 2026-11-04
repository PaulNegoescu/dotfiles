export DOTFILES="$HOME/.dotfiles"

# Load configs
source "$DOTFILES/zsh/path.zsh"
source "$DOTFILES/zsh/env.zsh"
source "$DOTFILES/zsh/options.zsh"
source "$DOTFILES/zsh/aliases.zsh"
source "$DOTFILES/zsh/completion.zsh"
source "$DOTFILES/zsh/key-bindings.zsh"

# Load plugins
source "$DOTFILES/zsh/plugins/zsh-shift-select.plugin.zsh"

# Set the window title nicely no matter where you are
DISABLE_AUTO_TITLE="true"
_set_terminal_title() {
  local title="$(basename "$PWD")"
  if [[ -n $SSH_CONNECTION ]]; then
    title="$title \xE2\x80\x94 $HOSTNAME"
  fi
  print -Pn "\e]2;$title\a"
}
# Call the function before displaying the prompt
precmd_functions+=(_set_terminal_title)

source "$DOTFILES/zsh/init.zsh"

# Allow local (private) overrides if present (PATH additions, work-specific aliases, etc.)
[ -f ~/.zsh.local ] && source ~/.zsh.local

# pnpm global executables
if [[ "$OSTYPE" == darwin* ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
# Newer pnpm releases put global executables in $PNPM_HOME/bin; older ones
# used $PNPM_HOME itself. Add both (the bin directory wins) on every platform.
for pnpm_bin in "$PNPM_HOME" "$PNPM_HOME/bin"; do
  case ":$PATH:" in
    *":$pnpm_bin:"*) ;;
    *) export PATH="$pnpm_bin:$PATH" ;;
  esac
done
unset pnpm_bin

# Add GPG key
GPG_TTY=$(tty 2> /dev/null || true)
export GPG_TTY
