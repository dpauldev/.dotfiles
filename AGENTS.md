# AGENTS.md — ~/.dotfiles

This file is read automatically by every AI coding agent (Claude Code,
GitHub Copilot, Cline) at the start of a session in this repository. It
is project-level persistent context: instructions that would otherwise
have to be re-typed every time.

## About this project

A personal macOS dotfiles repo shared across two machines with different
roles (see README.md for the full architecture diagram).

## What this repo is

- `Brewfile` — packages common to every machine.
- `Brewfile.dev` — extras for the primary dev workstation only.
- `Brewfile.spare` — extras for the lightweight secondary Mac only.
- `scripts/install_packages.sh` always installs the shared `Brewfile`, then
  picks the role-specific file via `uname -m`, with `~/.dotfiles-profile`
  (outside the repo) as a manual override when the chip alone isn't a
  reliable signal.
- `git/.gitconfig` is meant to be pulled in by `~/.gitconfig` via an
  `[include]` directive. That include has been unreliable in practice —
  `user.name`/`user.email` sometimes fail to resolve from it even though
  the file, path, and syntax all check out. Known working fallback: set
  `git config --global user.name` / `user.email` directly rather than
  fighting the include.
- Custom shell functions live in `oh_my_zsh/custom/functions.zsh`, each
  documented with `@desc` / `@usage` / `@requires` / `@credit` tags. Run
  `fndoc` to list them all. `dotfiles-audit` is the one you'll use most:
  it's read-only and diffs `brew leaves` / `brew list --cask` against
  what's actually declared across the three Brewfiles, so you can see
  what's installed-but-undeclared before anything gets added or removed.

## Package hygiene workflow

When asked to clean up or audit installed packages, follow this order and
stop between steps for confirmation before anything destructive:

1. `dotfiles-audit` — read-only, see what's undeclared.
2. `brew autoremove -n` — dry run, to distinguish real orphaned
   dependencies from formulae the user explicitly asked for
   (`brew list --installed-on-request`). Never treat `brew autoremove`'s
   real (non-`-n`) run as safe-by-default; confirm the list first.
3. `brew cleanup` only removes the download cache in
   `~/Library/Caches/Homebrew/`, never installed formulae in the Cellar —
   don't let a large number reported by `cleanup` be mistaken for packages
   being removed.

Gotcha to watch for: some packages are cask-only with no core formula
(e.g. `hiddenbar`). Using `brew "x"` for a cask-only package fails
silently in confusing ways — double check `brew`/`cask` keyword against
`brew info <name>` before adding a new line to any Brewfile.

`languagetool` (in the shared `Brewfile`) has no prebuilt bottle for older
macOS versions and can fail to build from source there (needs a newer
linker than old Xcode ships). If a bootstrap run fails on it on the spare
Mac, that's the known cause — the fix under discussion is moving it to a
machine-specific Brewfile rather than fighting the build.

## Commit conventions

- Imperative mood, capitalized, single line (e.g. `Split Brewfile for
  multi-machine support`, not `splitting brewfile` or `Fixed: brewfile`).
- No bracket/tag prefixes like `[fix]` or `feat:`.
- Before pushing, sanity-check `git log -1` shows the right author — the
  `[include]` issue above has caused commits to be attributed to the
  wrong identity before. If a commit hasn't been pushed yet, it's safe to
  fix with `git commit --amend --reset-author --no-edit`; once pushed,
  don't amend — a new corrective commit is safer than rewriting shared
  history.

## Maintaining this file

Keep it lean. Task-specific procedures belong in a skill, not here — this
file loads in full, every session, whether relevant or not. Add a
reference or rule only once it's in active use, not speculatively for
something that might come up later.
