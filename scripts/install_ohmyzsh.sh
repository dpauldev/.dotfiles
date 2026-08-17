#!/bin/bash

# Stop execution if an error occurs
set -e

echo "Checking Oh My Zsh..."

if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh already installed ✓"
else
    echo "Installing Oh My Zsh..."

    # Oh My Zsh installer options to keep bootstrap non-interactive:
    #
    # RUNZSH=no
    #   Do not launch a new zsh session after installation.
    #
    # CHSH=no
    #   Do not change the user's default shell.
    #
    # KEEP_ZSHRC=yes
    #   Preserve existing ~/.zshrc because dotfiles manages it.    

    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    echo "Oh My Zsh installation complete ✓"
fi

