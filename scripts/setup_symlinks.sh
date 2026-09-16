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

# If .zshrc is already a symlink, verify it points to the correct dotfiles version.
# -L tests specifically for "is this a symlink" — even a broken one whose target no longer exists. Checking -L before -e (below) matters: a dangling symlink would otherwise slip past this check and be treated like a normal file in the branch below.
if [ -L "$TARGET" ]; then

    # readlink prints the path a symlink actually points to
    CURRENT=$(readlink "$TARGET")

    if [ "$CURRENT" = "$SOURCE" ]; then
        echo ".zshrc already linked ✓"
    else
        echo ".zshrc is linked to another location:"
        echo "$CURRENT"
        exit 1
    fi


# If a normal .zshrc exists, preserve it before creating the symlink.
# -e matches anything already at this path — reached only once TARGET is confirmed not to be a symlink already, per the -L check above
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
