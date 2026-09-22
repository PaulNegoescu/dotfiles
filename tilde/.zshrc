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
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

# Add GPG key
export GPG_TTY=$(tty)
