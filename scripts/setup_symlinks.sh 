#!/bin/bash

# Stop execution if an error occurs
set -e

DOTFILES="$HOME/.dotfiles"

echo "Checking Zsh configuration..."

# Source file managed by this dotfiles repository
SOURCE="$DOTFILES/oh_my_zsh/.zshrc"

# Location where Zsh expects the configuration file
TARGET="$HOME/.zshrc"

# Ensure dotfiles source file exists before creating symlink
if [ ! -f "$SOURCE" ]; then
    echo "Source .zshrc not found:"
    echo "$SOURCE"
    exit 1
fi

# If .zshrc is already a symlink, verify it points to our dotfiles version
if [ -L "$TARGET" ]; then

    CURRENT=$(readlink "$TARGET")

    if [ "$CURRENT" = "$SOURCE" ]; then
        echo ".zshrc already linked ✓"
    else
        echo ".zshrc is linked to another location:"
        echo "$CURRENT"
        exit 1
    fi


# If a normal .zshrc exists, preserve it before creating the symlink
elif [ -e "$TARGET" ]; then

    BACKUP="$TARGET.backup-$(date +%Y-%m-%d-%H%M%S)"

    echo "Existing .zshrc found."
    echo "Creating backup:"
    echo "$BACKUP"

    mv "$TARGET" "$BACKUP"

    # Link Zsh configuration to the version-controlled dotfiles repository
    ln -s "$SOURCE" "$TARGET"

    echo ".zshrc linked ✓"


# Fresh machine: create the symlink directly
else

    # Connect system configuration location with dotfiles-managed file
    ln -s "$SOURCE" "$TARGET"

    echo ".zshrc linked ✓"

fi

