#!/run/current-system/sw/bin/zsh --login
#####!/usr/bin/env zsh --login

# set -u
# set -x

for script in $(run-parts --list $HOME/.xsession.d); do
  echo I: sourcing ${script}... >&2
  . $script
  echo I: done sourcing ${script}... >&2
done

# exec xmonad

# exit 0
