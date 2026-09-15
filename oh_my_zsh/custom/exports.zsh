# Homebrew
# Disable anonymous analytics collection
export HOMEBREW_NO_ANALYTICS=1


# Default command-line editor
# --wait keeps terminal processes open until editing is complete
# Falls back to vim on machines without VS Code installed (e.g. the spare Mac)
if command -v code >/dev/null 2>&1; then
    export EDITOR="code --wait"
    export VISUAL="code --wait"
else
    export EDITOR="vim"
    export VISUAL="vim"
fi
