#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/dotfiles"

# Ensure zsh is installed
if ! command -v zsh >/dev/null 2>&1; then
    echo "Installing zsh..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v brew >/dev/null 2>&1; then
            echo "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install zsh
    else
        # Assume Debian/Ubuntu
        sudo apt update && sudo apt install -y zsh
    fi
fi

# Install Oh My Zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    if command -v curl >/dev/null 2>&1; then
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo "curl not available, cannot install Oh My Zsh"
        exit 1
    fi
fi

zsh -c 'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"'
zsh -c 'git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'
zsh -c 'git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting'

rm -f "$HOME/.zshrc" "$HOME/.gitconfig"

ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
ln -sf "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

# Install fonts
if [ -d "$DOTFILES_DIR/fonts" ]; then
    echo "Installing fonts..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        FONT_DIR="$HOME/Library/Fonts"
    else
        # Linux
        FONT_DIR="$HOME/.fonts"
    fi
    mkdir -p "$FONT_DIR"
    cp -r "$DOTFILES_DIR/fonts/"* "$FONT_DIR/" 2>/dev/null || true
    if [[ "$OSTYPE" != "darwin"* ]] && command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f -v
    fi
    echo "Fonts installed successfully."
else
    echo "No fonts directory found in $DOTFILES_DIR"
fi

