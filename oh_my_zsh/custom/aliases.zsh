# Navigation
alias dotfiles="cd ~/.dotfiles"
alias aitools="cd ~/.aitools-config"
alias home="cd ~"

# .aitools-config scripts — aiinit copies a reusable template (CLAUDE.md,
# AGENTS.md, a skill, a hook, an agent) into whatever project you're
# currently in; ailink re-applies the symlinks/copies into ~/.claude,
# Copilot, and Cline after editing anything under aitools-config/shared/
alias aiinit="~/.aitools-config/scripts/init_project.sh"
alias ailink="~/.aitools-config/scripts/setup_symlinks.sh"

# Corrects the common typo of forgetting the space after cd — "cd.." on its own would otherwise be an unrecognized command, not the same as "cd .."
alias cd..="cd .."

# Shell
alias reload="source ~/.zshrc"

# Safety
# Blocks '>' from silently overwriting an existing file (e.g. "echo x > f" fails if f already exists) — use '>|' instead when you really mean to
set -o noclobber

# -i prompts "remove file? [y/n]" before each deletion — worth having since rm, unlike dragging a file to Trash, deletes permanently with no undo
alias rmi="rm -i"

# File operations
# -i prompts before overwriting a file that already exists at the destination (same idea as rmi above, applied to copying/moving instead of deleting); -v prints each "source -> destination" pair as it happens, so you can onfirm what actually got copied or moved
alias cpi="cp -iv"
alias mvi="mv -iv"

# Networking
alias cl="curl -L"  # -L follows redirects

# Modern CLI tools
# -l long format (permissions, size, modified date, etc.); -a also shows hidden dotfiles/dotfolders that a plain "eza" would otherwise skip
alias ll="eza -la"

# Shorthand for launching lazygit's terminal UI in the current repo
alias lg="lazygit"

# Overrides the built-in cat with bat (adds syntax highlighting). To reach the real cat directly if ever needed, use "command cat" or "\cat"
alias cat="bat"
