# Note: The first added entry gets referenced last

if command -v getconf &> /dev/null; then
  PATH="$(getconf PATH)"
fi

# Prepend PATH by skipping duplicates
declare -U PATH
prepend() {
  [ -d "$1" ] && PATH="$1:$PATH"
}

# Common local CLI install locations
prepend "/usr/local/bin"
prepend "$HOME/.local/bin"

# Homebrew binaries
# > $(brew --prefix)
homebrew_path="/opt/homebrew"
prepend "$homebrew_path/bin"
prepend "$homebrew_path/sbin"

# fnm, Node version manager: https://github.com/Schniz/fnm
# Tell fnm explicitly that we're using zsh to avoid brittle autodetection
if command -v fnm &> /dev/null; then
  eval "$(fnm env --use-on-cd --version-file-strategy=recursive --shell zsh)"
fi

# Custom dotfiles binaries
prepend "$HOME/dotfiles/bin/lib"
prepend "$HOME/dotfiles/bin"

# User binaries
prepend "$HOME/bin"

# Prevent it from being used accidentally elsewhere in the script or by other scripts
unset prepend

export PATH
