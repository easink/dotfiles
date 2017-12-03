#!/bin/zsh --login

set -u
# set -x

for script in $(run-parts --list $HOME/.xsession.d); do
  echo I: sourcing ${script}... >&2
  . $script
  echo I: done sourcing ${script}... >&2
done

exit 0
