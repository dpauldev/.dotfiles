#!/bin/bash

# Stop execution if an error occurs
set -e

echo "Checking Homebrew..."

if command -v brew >/dev/null 2>&1; then
    echo "Homebrew already installed ✓"
else
    echo "Homebrew not found. Installing..."

    # Homebrew's official installer (as of Sept 2026) refuses to run at all
    # on Intel Macs — it aborts with "Homebrew on macOS is only supported
    # on Apple Silicon processors!" (Homebrew/install commit e078684,
    # 2026-09-04). Homebrew itself still works fine on Intel once installed
    # (Tier 3 support until Sept 2027) — only the bootstrap script added
    # this block. So: Apple Silicon uses the current official installer;
    # Intel is pinned to commit f4aa1b1, the last version before that
    # check was added. Revisit/remove this once Intel support is dropped
    # entirely, or once a real fix/alternative exists upstream.
    case "$(uname -m)" in
        arm64) INSTALL_SCRIPT_REF="HEAD" ;;
        *)     INSTALL_SCRIPT_REF="f4aa1b1ca5b256954dbde0315455fb259cdfc45a" ;;
    esac

    # Downloads Homebrew's install script and runs it directly
    # (curl fetches the script's text; $(...) captures it as a string;
    # bash -c executes that string) — the standard one-line-installer
    # pattern used by many CLI tools, not something specific to this repo
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/$INSTALL_SCRIPT_REF/install.sh)"

    echo "Homebrew installation complete ✓"
fi
