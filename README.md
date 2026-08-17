# .dotfiles

Personal macOS development environment and configuration.

A reproducible workstation setup focused on developer productivity,
automation, and terminal workflow optimization.

---

## Contents

- Git configuration
- Oh My Zsh configuration
- Homebrew package management
- Shell productivity tools
- Bootstrap automation scripts

---

## Repository Structure

.dotfiles/
├── README.md
├── Brewfile
│
├── git/
│   └── .gitconfig
│
├── oh_my_zsh/
│   ├── .zshrc
│   └── custom/
│       ├── aliases.zsh
│       ├── exports.zsh
│       ├── functions.zsh
│       └── plugins/
│           ├── zsh-autosuggestions/
│           └── zsh-syntax-highlighting/
│
└── scripts/
    ├── bootstrap.sh
    ├── install_homebrew.sh
    ├── install_packages.sh
    ├── install_ohmyzsh.sh
    └── setup_symlinks.sh

---

## Bootstrap Setup

For a new machine:

git clone git@github.com:dpauldev/.dotfiles.git ~/.dotfiles

cd ~/.dotfiles

./scripts/bootstrap.sh

Bootstrap performs:

1. Install Homebrew
2. Install packages from Brewfile
3. Install Oh My Zsh
4. Create configuration symlinks

---

## Developer CLI Tools

| Tool | Purpose |
|---|---|
| eza | Modern replacement for ls |
| bat | Better cat with syntax highlighting |
| fd | Faster find replacement |
| fzf | Fuzzy finder |
| ripgrep | Fast text search |
| zoxide | Smarter directory navigation |
| lazygit | Terminal Git UI |
| git-delta | Improved Git diff viewer |
| gh | GitHub CLI |
| jq | JSON processing |
| yq | YAML processing |
| httpie | Modern API client |
| starship | Terminal prompt |

---

## Architecture

Git configuration:

~/.gitconfig
      |
      | include
      ↓
~/.dotfiles/git/.gitconfig


Zsh configuration:

~/.zshrc
      |
      | symlink
      ↓
~/.dotfiles/oh_my_zsh/.zshrc
      |
      | ZSH_CUSTOM
      ↓
~/.dotfiles/oh_my_zsh/custom/

---

## Philosophy

The goal is to keep my development environment:

- Version controlled
- Reproducible
- Portable
- Automated
- Organized by responsibility

Configuration is separated by purpose instead of one large configuration file.

---

## Future Improvements

- macOS preferences automation
- Terminal multiplexer configuration
- Editor configuration
- AI engineering workstation setup
- Container and cloud tooling

---

## Credits

Some shell utilities are adapted from open-source dotfiles projects.

Credits are preserved inside individual configuration files where applicable.
