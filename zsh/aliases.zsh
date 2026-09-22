# TIP: for a full list of active aliases, run `alias`

# Enable aliases to be sudo’ed
alias sudo="sudo "

# Easier navigation
alias .="printf '\U000F17A9 ' && pwd"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias cd..="cd .."
alias -- -="cd -" # previous working directory

# Hot-access directories
alias library="cd $HOME/Library"
alias proj="cd $WORKSPACE"
alias forks="cd $WORKSPACE/forks"
alias i="cd $WORKSPACE/oss"

# zshrc config
alias zshrc="$EDITOR ~/.zshrc"
alias reload="source ~/.zshrc && echo 'Shell config reloaded from ~/.zshrc'"
alias s="reload"

# Sane defaults for built-ins (verbose and interactive)
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias grep="grep -i --color=auto"
alias mkdir="mkdir -p"

# Typos
alias sl="ls"
alias gut="git"
alias gti="git"
alias mdkir="mkdir"
alias brwe="brew"

# Shortcuts
alias -- +x="chmod +x"
alias o="open"
alias oo="open ."
alias g="git"
alias d="docker"
alias dc="docker compose"
alias e="$EDITOR"
alias c="code ."
alias cc="code ."
alias where="which"
alias python="python3"

# Node Package Manager
alias pn="pnpm"
alias nvm="fnm"

# Apps

# File Manager
alias ff="open -a 'Marta' ."

#
# Built-ins upgrades
#

command_exists() {
  command -v "$@" &> /dev/null
}

# Bat: https://github.com/sharkdp/bat
command_exists bat && alias cat="bat --style=plain"

# Fd: https://github.com/sharkdp/fd
command_exists fd && alias find="fd"

# Eza: https://eza.rocks/
# Display all clickable entries as a grid with icons
command_exists eza && alias ls="eza --no-user --hyperlink --icons=auto --group-directories-first --color-scale=age"
# ...(incl. hidden files)
command_exists eza && alias lsa="ls -a"
# Display a detailed clickable directory tree with a Git status
command_exists eza && alias lt="ls --tree --level=2 --long --header --git --git-ignore"
# ...(incl. hidden files)
command_exists eza && alias lta="lt -a"

# Safer reversible file removal: https://github.com/sindresorhus/trash-cli
command_exists trash && alias rm="trash"

# Btop: https://github.com/aristocratos/btop
command_exists btop && alias top="btop"

# Tlrc: https://github.com/tldr-pages/tlrc
command_exists tldr && alias man="tldr --config ~/.tlrc.toml"

# Download file and save it with the name of the remote file in the current working directory
# Usage: get <URL>
alias get="curl -O -L"

#
# Helpers
#

# Most used Git shortcuts
alias gs="git rev-parse --git-dir > /dev/null 2>&1 && git status -sb || ls"
alias gcm="git commit -m"
alias gaa="git add -A"
alias gd="git d"
alias gdc="git dc"
alias gl="git l"
alias gpuf="push --force-with-lease"

# Preview and open files in the current dir
command_exists fzf && command_exists bat && alias preview="fzf --preview 'bat --style=numbers --color=always {}'"

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'

# Cd to the root directory of the current Git repository
alias gitroot='cd "$(git rev-parse --show-toplevel)"'
alias gr="gitroot"

# Cd into the directory shown by the front-most Finder window
# Based on https://scriptingosx.com/2017/02/terminal-finder-interaction/
cdf() {
  cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')"
}

# Make a new directory and cd into it
take() {
  \mkdir -p "$1" && cd "$1"
}

function git() {
  # Clone a GitHub repo and cd into the created directory
  if [[ "${1:-}" == "clone" ]]; then
    command git "$@" || return

    local repo_dir
    if [[ -n "${3:-}" ]]; then
      repo_dir="$3"
    else
      repo_dir="$(basename "$2" .git)"
    fi

    cd "$repo_dir" || return

    if [[ -r "./pnpm-lock.yaml" ]]; then
      pnpm install
    elif [[ -r "./package-lock.json" ]]; then
      npm ci
    elif [[ -r "./yarn.lock" ]]; then
      corepack yarn install
    fi
  else
    command git "$@"
  fi
}

#
# macOS
#

# System
alias shutdownmac="sudo shutdown -h now"
alias restartmac="sudo shutdown -r now"

# Show/hide all desktop icons (useful when presenting)
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
