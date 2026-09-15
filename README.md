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
- Self-documenting custom functions
- Bootstrap automation scripts

---

## Repository Structure

```
.dotfiles/
├── README.md
├── LICENSE
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
```

---

## Bootstrap Setup

For a new machine:

```bash
git clone git@github.com:dpauldev/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/bootstrap.sh
```

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
| languagetool | Local grammar/style checking server (used by `lt`) |
| translate-shell | Command-line translation (used by `td`/`te`) |
| speedtest | Official Ookla internet speed test |

---

## Custom Functions

Custom shell functions live in `oh_my_zsh/custom/functions.zsh`, each documented with a small set of tags in the comment block directly above it:

- `@desc` — what the function does
- `@usage` — how to call it, including any arguments
- `@requires` — an external dependency needed for it to work, if any
- `@credit` — the external source it was adapted from, when applicable (see Credits below)

Run `fndoc` to list every custom function along with its usage and description, generated live from these tags — so this README never goes stale when a function is added.

---

## Architecture

Git configuration:

```
~/.gitconfig
      |
      | include
      ↓
~/.dotfiles/git/.gitconfig
```

Zsh configuration:

```
~/.zshrc
      |
      | symlink
      ↓
~/.dotfiles/oh_my_zsh/.zshrc
      |
      | ZSH_CUSTOM
      ↓
~/.dotfiles/oh_my_zsh/custom/
```

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

Some shell utilities are adapted from open-source dotfiles projects. Each adapted function carries an `@credit` tag in `functions.zsh` pointing to its source.

---

## AI Assistance

Some functions and scripts in this repository were developed with AI assistance. Functions without an `@credit` tag in `functions.zsh` fall into this category.

---

## License

MIT — see [LICENSE](./LICENSE).
