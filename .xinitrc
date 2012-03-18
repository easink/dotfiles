
PATH=$PATH:/usr/sbin

FONT="-*-lime-*-*-*-*-*-*-*-*-*-*-iso10646-*"

[[ -f ~/.Xdefaults ]] && xrdb -merge ~/.Xdefaults

exec xmonad
