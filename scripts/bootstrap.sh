#!/bin/bash

# Stop execution if error occurs
set -e

DOTFILES="$HOME/.dotfiles"

echo "Starting dotfiles bootstrap..."

echo ""
echo "Step 1: Installing Homebrew"
"$DOTFILES/scripts/install_homebrew.sh"

echo ""
echo "Step 2: Installing Homebrew packages"
"$DOTFILES/scripts/install_packages.sh"

echo ""
echo "Step 3: Installing Oh My Zsh"
"$DOTFILES/scripts/install_ohmyzsh.sh"

echo ""
echo "Step 4: Setting up symlinks"
"$DOTFILES/scripts/setup_symlinks.sh"

echo ""
echo "Bootstrap complete ✓"

