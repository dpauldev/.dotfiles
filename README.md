# .dotfiles

Personal macOS development environment and configuration.

## Contents

- **Git**
  - Global Git configuration
  - GitHub identity settings

- **Oh My Zsh**
  - Shell configuration
  - Custom aliases and functions

- **Shell**
  - Personal utilities and workflow improvements

- **Scripts**
  - Setup and automation scripts (planned)

---

## Repository Structure

```text
.dotfiles/
│
├── README.md
├── .gitignore
│
├── git/
│   └── .gitconfig
│
└── oh_my_zsh/
    ├── .zshrc
    └── custom/
        ├── aliases.zsh
        └── functions.zsh
```

---

## Architecture

This repository keeps configuration version-controlled while allowing tools to use their expected locations.

### Git Configuration

```text
~/.gitconfig
      |
      | include
      ↓
~/.dotfiles/git/.gitconfig
```

### Zsh Configuration

```text
~/.zshrc
      |
      | symlink
      ↓
~/.dotfiles/oh_my_zsh/.zshrc
      |
      | ZSH_CUSTOM
      ↓
~/.dotfiles/oh_my_zsh/custom/
      |
      ├── aliases.zsh
      └── functions.zsh
```

---

## Philosophy

The goal is to keep my development environment:

- Version controlled
- Reproducible
- Portable
- Organized by purpose

Configuration is separated by responsibility rather than stored in a single large file.

---

## Future Improvements

Planned additions:

- Homebrew Brewfile
- Bootstrap script for new machines
- Developer tooling configuration
- macOS preferences and automation scripts

---

## Credits

Some shell utilities are adapted from open-source dotfiles projects.

Credits are preserved inside individual configuration files where applicable.
