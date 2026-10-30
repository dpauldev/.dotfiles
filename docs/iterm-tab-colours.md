# iTerm2 tab colours for remote logins

One iTerm2 tab is often used for several places: the Mac, a server as an admin user, a server as a service user. A different background colour and badge for each place warns you before a command is typed in the wrong one.

This guide shows how to paint the tab from the remote shell, and how to make sure the colour never stays behind when a connection ends. It applies to iTerm2 only. In other terminals the Mac-side hook does nothing.

## How it works

iTerm2 obeys private escape codes printed to the terminal:

| Code | Effect |
|---|---|
| `\033]1337;SetColors=bg=<hex>\a` | Paints this tab's background, for example `4a0c0c` |
| `\033]1337;SetBadgeFormat=<base64>\a` | Sets the badge text. The text must be base64 encoded |
| `\033]1337;SetProfile=<name>\a` | Switches the tab to the named profile. This also clears any painted colour and badge |

The colour is not a profile setting. It is painted by the shell that prints the code, so whichever shell ran last decides the colour.

## The three iTerm2 profiles

The tab colours come from the shells, but each place also has an iTerm2 profile, used when you open a tab for it:

| Profile | Command | Badge | Notes |
|---|---|---|---|
| Local (the default) | Login shell | None | Your normal Mac tab: the colour a tab goes back to |
| Server admin | `ssh <alias>`, not run through a shell | `SERVER ADMIN` | A tab opened from this profile is the ssh connection and nothing else. When it ends there is no Mac shell underneath, so no Mac prompt returns and the hook in Step 3 has nothing to run on. What the tab does then depends on the profile's session-end setting, which this guide has not checked |
| Server service | Login shell, no text sent at start | `SERVER SERVICE` | A Mac shell that starts painted in the service colour. It does not log in anywhere. Its behaviour at the first prompt has not been tested; expect the Step 3 hook to reset it to the local colour |

- The profile names must match the names in the codes exactly. Step 2 and Step 3 use `Local Mac`, so name your default profile that, or change the name in both places.
- In the usual flow you open a Local tab, run `ssh <alias>`, and then switch to the service user with `sudo -iu <user>`. The profiles for the other two are a convenience; the codes in the steps below do the actual switching.

## Step 1: paint on the remote side

Add a block to the end of `~/.bashrc` of each account on the server, with its own colour and badge text:

```
# >>> terminal-identity (iTerm2 colour + badge) >>>
_term_identity() {
  printf '\033]1337;SetBadgeFormat=%s\a' "$(printf 'SERVER ADMIN' | base64)"
  printf '\033]1337;SetColors=bg=4a0c0c\a'
}
PROMPT_COMMAND="_term_identity${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
# <<< terminal-identity <<<
```

- `PROMPT_COMMAND` runs just before every prompt is drawn, so the colour is repainted each time and cannot go stale. This is also why leaving a nested shell (for example after `sudo -iu otheruser`) returns to the outer shell's colour at its next prompt.
- Use a different hex colour and badge text in each account's file.

## Step 2: reset on a clean exit (optional)

In the account you log into first, add:

```
# >>> terminal-identity-reset >>>
if [ "$SHLVL" = 1 ]; then
  trap "printf '\033]1337;SetProfile=Local Mac\a'" EXIT
fi
# <<< terminal-identity-reset <<<
```

`SHLVL = 1` limits the trap to the outermost shell. Replace `Local Mac` with the exact name of your normal iTerm2 profile.

## The problem this leaves

The reset above is printed by the server. If the connection ends on its own (an idle timeout, a lost network, a killed process), the server cannot print anything, and the tab keeps the server's colour at the Mac prompt.

## Step 3: reset from the Mac side

This repository ships a hook, `oh_my_zsh/custom/iterm-reset.zsh`. It prints the same `SetProfile` code before every prompt on the Mac, so however a session ended, the Mac prompt clears the paint. It does nothing outside iTerm2 because it checks `$TERM_PROGRAM`. Oh My Zsh loads every `*.zsh` file in its `custom` folder, so no other setup is needed beyond having `ZSH_CUSTOM` point there.

Side effect: a colour or font size you change by hand in a Mac tab is undone at the next prompt.

## Check that it works

1. Log in to the server. The tab turns the account's colour.
2. Run `exit`. The tab returns to normal.
3. Log in again, then end the session abruptly, for example `kill -9 $$` (the exit trap cannot run). The tab should still return to normal when the Mac prompt appears.

## Limits

- Tested in iTerm2 only. The built-in macOS Terminal should ignore the codes, but this has not been verified.
- `ssh` inside `tmux` or other multiplexers has not been tested.
- The server blocks are written for bash. For zsh, run the paint function from a `precmd` hook and use a `zshexit` hook instead of `trap`.
