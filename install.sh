#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/dotfiles"

zsh -c 'git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'
zsh -c 'git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting'

ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
ln -sf "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

# Install fonts
if [ -d "$DOTFILES_DIR/fonts" ]; then
    echo "Installing fonts..."
    # Ensure fontconfig is available
    if command -v fc-cache >/dev/null 2>&1; then
        cp -r "$DOTFILES_DIR/fonts/"* "/usr/local/share/fonts/" 2>/dev/null || true
        fc-cache -f -v
        echo "Fonts installed successfully."
    else
        echo "fontconfig not available, skipping font installation"
    fi
else
    echo "No fonts directory found in $DOTFILES_DIR"
fi

