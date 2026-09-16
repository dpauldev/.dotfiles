#!/bin/bash

# Stop execution if error occurs
set -e

DOTFILES="$HOME/.dotfiles"

echo "Starting dotfiles bootstrap..."

# Steps run in this specific order because each one depends on the previous succeeding (e.g. package installation needs Homebrew already installed) —
# set -e above ensures a failed step stops the chain rather than continuing on a broken/incomplete environment

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
