#!/bin/bash

# Stop execution if an error occurs
set -e

DOTFILES="$HOME/.dotfiles"

echo "Installing Homebrew packages..."

if command -v brew >/dev/null 2>&1; then
    brew bundle --file "$DOTFILES/Brewfile"
    echo "Homebrew packages installed ✓"
else
    echo "Homebrew not found. Please install Homebrew first."
    exit 1
fi
