#!/bin/bash

# Stop execution if an error occurs
set -e

echo "Checking Homebrew..."

if command -v brew >/dev/null 2>&1; then
    echo "Homebrew already installed ✓"
else
    echo "Homebrew not found. Installing..."

    # Downloads Homebrew's official install script and runs it directly
    # (curl fetches the script's text; $(...) captures it as a string; bash -c executes that string) — the standard one-line-installer pattern used by many CLI tools, not something specific to this repo
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    echo "Homebrew installation complete ✓"
fi
