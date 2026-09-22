#!/bin/bash

set -euo pipefail

DRY_RUN=false

case "${1:-}" in
  --dry-run)
    DRY_RUN=true
    ;;
  "") ;;
  *)
    echo "Usage: $0 [--dry-run]" >&2
    exit 1
    ;;
esac

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
TILDE_DIR="$DOTFILES_DIR/tilde"

EXCLUDE_FILES=(".DS_Store" "Brewfile.lock.json" "README.md" ".ssh")

indent() {
  sed 's/^/  /'
}

tildify() {
  printf '%s' "${1/#$HOME/~}"
}

info() {
  printf "$1" | indent
  echo
}

user() {
  printf "\r  [ \033[0;33m?\033[0m ] $1 "
}

success() {
  printf "\r\033[2K   $1\n"
}

skipped() {
  printf "\r\033[2K  [skipped]  $1\n"
}

preview() {
  printf '  [dry-run] %s\n' "$1"
}

fail() {
  printf "\r\033[2K  [\033[0;31m✖\033[0m] $1\n"
  echo ''
  exit 1
}

symlink_file() {
  local src=$1 dst=$2 isHardLink=${3:-false}

  local overwrite=""
  local backup=""
  local skip=""
  local action=""

  if [ "$DRY_RUN" = true ]; then
    if [ ! -e "$src" ] && [ ! -L "$src" ]; then
      preview "source is missing: $src"
    elif [ -L "$dst" ] && [ "$(readlink "$dst")" == "$src" ]; then
      preview "already linked: $(tildify "$dst")"
    elif [ -e "$dst" ] || [ -L "$dst" ]; then
      preview "would prompt before replacing: $(tildify "$dst")"
    else
      preview "would link $(tildify "$dst") -> $src"
    fi

    return
  fi

  if [ ! -e "$src" ] && [ ! -L "$src" ]; then
    fail "Source does not exist: $src"
  fi

  if [ ! -d "$(dirname "$dst")" ]; then
    mkdir -p "$(dirname "$dst")"
  fi

  # First, check if the destination file or folder exists
  if [ -e "$dst" ]; then

    # Check if the destination is a hard link to the same inode as the source
    # (only meaningful when `isHardLink=true`, but `-ef` is harmless otherwise)
    if [ "$isHardLink" = true ] && [ "$dst" -ef "$src" ]; then
      # Already hard linked to the dotfiles source, skip overwriting
      skip=true

    # Check if the destination is a symlink
    elif [ -L "$dst" ]; then

      # Check if the destination is already a symlink to the dotfiles
      readlink_out=$(readlink "$dst")
      local current_src="$readlink_out"

      if [ "$current_src" == "$src" ]; then
        # Skip overwriting
        skip=true
      else
        # If the destination is a symlink to something else, ask to overwrite
        handle_existing_file
      fi

    else

      # If the destination is a regular file or directory, ask to overwrite
      handle_existing_file

    fi

  fi

  # "false" or empty
  if [ "$skip" != "true" ]; then
    local ln_cmd="ln"
    if [ ! -w "$(dirname "$2")" ]; then
      ln_cmd="sudo ln"
    fi

    if [ "$isHardLink" = true ]; then
      $ln_cmd -f "$1" "$2"
      success "$(tildify "$2")"
    else
      $ln_cmd -sf "$1" "$2"
      success "$(tildify "$2")"
    fi
  else
    skipped "$(tildify "$dst")"
  fi
}

handle_existing_file() {
  if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]; then
    user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
    [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
    read -n 1 action

    case "$action" in
      o)
        overwrite=true
        ;;
      O)
        overwrite_all=true
        ;;
      b)
        backup=true
        ;;
      B)
        backup_all=true
        ;;
      s)
        skip=true
        ;;
      S)
        skip_all=true
        ;;
      *)
        skip=true
        ;;

    esac
  fi

  overwrite=${overwrite:-$overwrite_all}
  backup=${backup:-$backup_all}
  skip=${skip:-$skip_all}

  if [ "$overwrite" == "true" ]; then
    rm -rf "$dst"
    success "removed $dst"
  fi

  if [ "$backup" == "true" ]; then
    local backup_path="${dst}.backup"

    if [ -e "$backup_path" ] || [ -L "$backup_path" ]; then
      backup_path="${dst}.backup.$(date +%Y%m%d%H%M%S)"
    fi

    mv "$dst" "$backup_path"
    success "moved $dst to $backup_path"
  fi
}

install_dotfiles() {
  info 'Syncing dotfiles…'

  local overwrite_all=false
  local backup_all=false
  local skip_all=false

  # Create .config directory if it doesn't exist
  if [ "$DRY_RUN" = false ]; then
    mkdir -p "$HOME/.config"
  fi

  cd "$TILDE_DIR"

  # Loop through all items in the `tilde` directory
  for item in .* *; do
    # Skip the current and parent directory entries
    if [ "$item" == "." ] || [ "$item" == ".." ]; then
      continue
    fi

    # Ignore exclude files
    for excluded in "${EXCLUDE_FILES[@]}"; do
      if [[ "$item" == "$excluded" ]]; then
        # Skip to the next iteration of the outer loop
        continue 2
      fi
    done

    # is a dotfile
    if [ -f "$item" ]; then
      src="$PWD/$item"
      dest="$HOME/$item"
      symlink_file "$src" "$dest"
    # is a dir with dotfiles
    elif [ -d "$item" ]; then
      if [ "$item" != ".config" ]; then
        src="$PWD/$item"
        dest="$HOME/$item"
        symlink_file "$src" "$dest"
      else
        # Handle the `.config` dir separately
        for config_item in "$item"/*; do
          src="$PWD/$config_item"
          dest="$HOME/$config_item"
          symlink_file "$src" "$dest"
        done
      fi
    fi
  done
}

install_extras() {
  local overwrite_all=false
  local backup_all=false
  local skip_all=false

  # Stable path for configs, regardless of where the repository is cloned
  symlink_file "$DOTFILES_DIR" "$HOME/.dotfiles"

  # Link only SSH configuration; preserve keys and other SSH files
  if [ "$DRY_RUN" = false ]; then
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
  fi

  symlink_file "$TILDE_DIR/.ssh/config" "$HOME/.ssh/config"

  if [ "$DRY_RUN" = false ] && [ ! -d "/usr/local/bin" ]; then
    echo "Administrator password required to create /usr/local/bin:"
    sudo mkdir -p "/usr/local/bin"
  fi

  #
  # VSCode
  #

  # Install `code` command in PATH
  command -v code &> /dev/null || {
    symlink_file "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" "/usr/local/bin/code"
  }
  # Enable settings sync from dotfiles
  vscode_user_folder="$HOME/Library/Application Support/Code/User"

  symlink_file \
    "$DOTFILES_DIR/vscode/User/settings.json" \
    "$vscode_user_folder/settings.json"

  symlink_file \
    "$DOTFILES_DIR/vscode/User/tasks.json" \
    "$vscode_user_folder/tasks.json"

  symlink_file \
    "$DOTFILES_DIR/vscode/User/snippets/global.code-snippets" \
    "$vscode_user_folder/snippets/global.code-snippets"
}

install_dotfiles
install_extras
echo
echo 'Done!' | indent
