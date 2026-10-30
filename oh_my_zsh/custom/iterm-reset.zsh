# iTerm2: reset the tab to the Local Mac profile before every prompt on this Mac.
# The server shells paint their own colour and badge and clear it only on a clean
# exit, so a dropped ssh session would otherwise leave that colour behind.
if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
  autoload -Uz add-zsh-hook
  _reset_iterm_profile() { printf '\033]1337;SetProfile=Local Mac\a' }
  add-zsh-hook precmd _reset_iterm_profile
fi
