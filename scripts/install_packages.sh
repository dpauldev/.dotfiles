#!/bin/bash

# Stop execution if an error occurs
set -e

DOTFILES="$HOME/.dotfiles"

echo "Installing Homebrew packages..."

if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Please install Homebrew first."
    exit 1
fi

# Always install the shared package set
brew bundle --file "$DOTFILES/Brewfile"
echo "Shared packages installed ✓"

# Determine this machine's role:
# 1. An explicit override file wins, if present (escape hatch for edge cases)
# 2. Otherwise, detect automatically from CPU architecture
if [[ -f "$HOME/.dotfiles-profile" ]]; then
    PROFILE=$(cat "$HOME/.dotfiles-profile" | tr -d '[:space:]')
else
    case "$(uname -m)" in
        arm64)  PROFILE="dev" ;;
        *)      PROFILE="spare" ;;
    esac
fi

PROFILE_FILE="$DOTFILES/Brewfile.$PROFILE"

if [[ -f "$PROFILE_FILE" ]]; then
    brew bundle --file "$PROFILE_FILE"
    echo "Machine-specific ($PROFILE) packages installed ✓"
else
    echo "No profile-specific Brewfile found for '$PROFILE' ($PROFILE_FILE) — skipping."
fi
