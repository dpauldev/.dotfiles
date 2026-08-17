#!/bin/bash

# Stop execution if an error occurs
set -e

echo "Checking Homebrew..."

if command -v brew >/dev/null 2>&1; then
    echo "Homebrew already installed ✓"
else
    echo "Homebrew not found. Installing..."

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    echo "Homebrew installation complete ✓"
fi
