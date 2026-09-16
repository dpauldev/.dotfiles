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
# 1. An explicit override file wins, if present (escape hatch for edge cases, e.g. a future machine where the chip alone can't tell dev vs. spare)
# 2. Otherwise, detect automatically from CPU architecture
if [[ -f "$HOME/.dotfiles-profile" ]]; then
    # Strip whitespace (including the trailing newline a text editor adds on save) so it can't silently corrupt the profile name used below
    PROFILE=$(cat "$HOME/.dotfiles-profile" | tr -d '[:space:]')
else
    case "$(uname -m)" in
        arm64)  PROFILE="dev" ;;
        # Catch-all: anything that isn't arm64 (Intel today, and any future non-Apple-Silicon chip) is treated as the spare machine
        *)      PROFILE="spare" ;;
    esac
fi

PROFILE_FILE="$DOTFILES/Brewfile.$PROFILE"

# Guard against a missing/misnamed profile file so the script skips this step gracefully instead of crashing — "set -e" above means any unhandled failing command would otherwise kill the whole script here
if [[ -f "$PROFILE_FILE" ]]; then
    brew bundle --file "$PROFILE_FILE"
    echo "Machine-specific ($PROFILE) packages installed ✓"
else
    echo "No profile-specific Brewfile found for '$PROFILE' ($PROFILE_FILE) — skipping."
fi
