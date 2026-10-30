# .dotfiles

Personal macOS development environment and configuration.

A reproducible workstation setup focused on developer productivity,
automation, and terminal workflow optimization.

---

## Contents

- Git configuration
- Oh My Zsh configuration
- Homebrew package management, split for multiple machines
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
├── Brewfile.dev
├── Brewfile.spare
│
├── docs/
│   └── iterm-tab-colours.md
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
│       ├── iterm-reset.zsh
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
2. Install packages — shared `Brewfile`, plus the role-specific `Brewfile.dev` or `Brewfile.spare`
3. Install Oh My Zsh
4. Initialize git submodules (the zsh plugins in `oh_my_zsh/custom/plugins/`)
5. Create configuration symlinks

---

## Multi-Machine Package Management

This repo supports more than one machine with different roles — a primary development workstation and a lightweight secondary machine — without maintaining a separate dotfiles repo for each.

- `Brewfile` — packages shared by every machine.
- `Brewfile.dev` — extra packages for the primary dev workstation only.
- `Brewfile.spare` — extra packages for the lightweight secondary machine only.

`scripts/install_packages.sh` always installs from the shared `Brewfile`, then detects which role-specific file to also install — by default via CPU architecture (`uname -m`), with an optional `~/.dotfiles-profile` file (kept outside the repo) as a manual override for cases where the chip alone isn't a reliable signal.

Run `dotfiles-audit` to check both directions of drift on the current machine: packages installed but not yet tracked in either the shared or role-specific Brewfile, and packages tracked there but no longer installed (for example after a `brew uninstall`). It is read-only; the Brewfile needs editing by hand to resolve what it reports — see `fndoc` for full usage.

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

- `fndoc` — list every function (names starting with `_` are internal helpers and hidden)
- `fndoc <name>` — one function in full, including its `@requires` and `@credit`
- `fndoc <keyword>` — any other word searches names, usage and descriptions, with the match highlighted
- `fndoc -s <keyword>` — force a search, even when the word is also a function name
- `fndoc -h` — help with examples

Text wraps to the terminal width, and `@desc` can continue over following comment lines.

### Aliases

Aliases come from two places: the Oh My Zsh plugins enabled in `~/.zshrc` (defined in memory by the plugin files, not in this repo) and the custom ones in `oh_my_zsh/custom/aliases.zsh`. Run `aliasdoc` to browse them all, grouped by where they were defined (`git`, `brew`, `custom`, `omz-core` for the Oh My Zsh core library, `other` for anything else, ...):

- `aliasdoc` — list the groups with alias counts
- `aliasdoc <group>` — show one group; any other word is searched for (names and expansions, with the match highlighted)
- `aliasdoc -s <word>` — force a search, even when the word is also a group name
- `aliasdoc -a` — everything, through a pager
- `aliasdoc -t [N] [-d DAYS]` — the most-used aliases, from shell history, with a trend (last `DAYS` days vs the `DAYS` before, default 30) and a count of aliases never used (only the first word of a command is counted, after skipping leading `time`, `nocorrect` and `VAR=value` words)
- `aliasdoc -m [N] [-d DAYS]` — "missed shortcuts": commands typed in full although an alias exists (`git status` → `gst`), most frequent first; `-d DAYS` limits it to the last `DAYS` days (default: all history). Only aliases for a multi-word command are considered, and a line counts toward the longest matching alias. Leading `time`, `nocorrect` and `VAR=value` words are ignored; `sudo` and `command` are not, because an alias does not expand after them
- `aliasdoc -h` — full help with examples (the authoritative list of options)

`ad` is a short alias for `aliasdoc` and takes the same arguments (`ad git`, `ad -t`).

Like `fndoc`, `aliasdoc` reads live state, so it never needs updating when aliases change (run `reload` to pick up edits). The `-t` and `-m` reports read the shell history file (`$HISTFILE`, read-only), so they only cover as many commands as `SAVEHIST` keeps, and they need timestamps in the history file (`EXTENDED_HISTORY`, set by Oh My Zsh).

#### Missed-alias reminder

The `alias-finder` plugin prints a hint such as `gst='git status'` when a command that has an alias is entered. A small hook (`_aliasmiss_hook` in `functions.zsh`) is registered after it, so its line appears underneath, and adds how often that command was typed in full, with or without further arguments (`git status` also counts `git status --long`, but not `git status --short` when that has its own alias, `gss`). It works on its own: with the plugin disabled, only this line is printed.

```
gst='git status'
  ↳ 'gst' missed: typed 'git status' in full 12x in the last 7 days
```

- Shown only from the 2nd time within the last 7 days, so a one-off command stays quiet. Lines starting with `time`, `nocorrect` or `VAR=value` are matched as the command after them. Aliases that save no typing (`ls='ls -G'`) are skipped, and a one-word expansion (`g='git'`) is only mentioned when the whole line is that word, so every `git ...` command is not counted as a miss.
- Counts come from the in-memory shell history, so they include the current session and, with `SHARE_HISTORY` on, other open terminals; the line being typed is always counted, even though zsh stores it only after the hook has run. Only the most recent 3000 entries are scanned, which bounds the cost whatever the history size (roughly 10 to 15 ms per hint). A shell that runs more than about 3000 commands in a week therefore undercounts. Two identical commands in a row are stored once (`histignoredups`), so back-to-back repeats count once, and a command typed with a leading space is never stored (`histignorespace`), so later hints do not count it.
- `aliasmiss off` / `aliasmiss on` switch it off and on, `aliasmiss status` shows the current state. The choice is remembered across shells by a marker file, `${XDG_STATE_HOME:-~/.local/state}/aliasmiss.off` (present means off); it lives outside the repo.
- The hook keeps one private (mode 600) scratch file per shell in `$TMPDIR`. It holds history text only while a hint is being computed, is emptied right after, and is removed when the shell exits; a shell killed with `SIGKILL` or replaced with `exec` can leave the file behind (usually empty).

### iTerm2 tab reset

`oh_my_zsh/custom/iterm-reset.zsh` resets the iTerm2 tab to the Local Mac profile before every prompt. The server shells paint their own colour and badge and clear it only on a clean exit, so without this a dropped ssh session leaves the server colour behind. It does nothing outside iTerm2.

For the full setup (server-side paint, clean-exit reset and this hook), see [docs/iterm-tab-colours.md](docs/iterm-tab-colours.md).

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

The goal is to keep the development environment:

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
