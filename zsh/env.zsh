#
# "global" system stuff
#

# Prefer US English and use UTF-8
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"

# Let each terminal emulator advertise its own capabilities through TERM.
export WORKSPACE="$HOME/work"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR="nano"
else
  export EDITOR="code --wait"
fi
export VISUAL="$EDITOR"

# Hide the “default interactive shell is now zsh” warning on macOS
export BASH_SILENCE_DEPRECATION_WARNING=1

#
# zsh stuff
#

# Enable history so we get auto suggestions
export HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history" # History filepath
export HISTSIZE=100000                           # Maximum events kept in memory for the current shell session
export SAVEHIST="$HISTSIZE"                      # Maximum events stored in history file

# Stop autocorrect from suggesting undesired completions
export CORRECT_IGNORE_FILE=".*"
export CORRECT_IGNORE="_*"

# Correction prompt
export SPROMPT="Correct '%R' to '%r' [nyae]?"

# Enable color output for CLI tools like ls and grep
export CLICOLOR=1

#
# commands
#

# Make less the default pager with added options

# Set up a preprocessor for the less pager
[ -n "$LESSPIPE" ] && export LESSOPEN="| ${LESSPIPE} %s"
less_options=(
  # If the entire text fits on one screen, just show it and quit. (Be more
  # like "cat" and less like "more")
  --quit-if-one-screen

  # Do not clear the screen first
  --no-init

  # Like "smartcase" in Vim: ignore case unless the search pattern is mixed
  --ignore-case

  # Do not automatically fold long lines to the next line
  --chop-long-lines

  # Allow ANSI colour escapes, but no other escapes
  --RAW-CONTROL-CHARS

  # Do not ring the bell when trying to scroll past the end of the buffer
  --quiet

  # Do not complain when we are on a dumb terminal
  --dumb
)
export LESS="${less_options[*]}"
# Disable the history file to not leave a trail of previously viewed files on the system
export LESSHISTFILE='-'
export PAGER='less'

# Privacy
# https://nextjs.org/telemetry
export NEXT_TELEMETRY_DISABLED=1
# https://docs.strapi.io/dev-docs/configurations/environment/#strapis-environment-variables
export STRAPI_TELEMETRY_DISABLED=1
# https://www.gatsbyjs.com/docs/telemetry/
export GATSBY_TELEMETRY_DISABLED=1
# https://astro.build/telemetry/
export ASTRO_TELEMETRY_DISABLED=1
# https://storybook.js.org/docs/configure/telemetry
export STORYBOOK_DISABLE_TELEMETRY=1
# https://vercel.com/docs/cli/about-telemetry#telemetry
export VERCEL_TELEMETRY_DISABLED=1
# https://github.com/aws/aws-cdk/issues/34892
export CDK_DISABLE_CLI_TELEMETRY=1
# https://docs.github.com/en/github-cli/github-cli/github-cli-telemetry#how-to-opt-out
export GH_TELEMETRY=false

# Node & NPM
export NPM_CONFIG_INIT_AUTHOR_NAME="Paul Negoescu"
export NPM_CONFIG_INIT_AUTHOR_URL="https://github.com/PaulNegoescu"
export NPM_CONFIG_INIT_LICENSE="MIT"
export NPM_CONFIG_INIT_VERSION="0.1.0"
export NPM_CONFIG_PROGRESS="true"
export NPM_CONFIG_SAVE="true"
export NPM_CONFIG_UPDATE_NOTIFIER="false"

# Homebrew: https://docs.brew.sh/Manpage#environment
export HOMEBREW_REQUIRE_TAP_TRUST=1
export HOMEBREW_INSTALL_BADGE='☕'
export HOMEBREW_NO_GITHUB_API=1
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_INSECURE_REDIRECT=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_UPDATE_REPORT_NEW=1
export HOMEBREW_BUNDLE_FILE="$DOTFILES/setup/Brewfile"
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# Ripgrep config file location
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
