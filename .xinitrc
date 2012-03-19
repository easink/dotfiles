
PATH=$PATH:/usr/sbin

FONT="-*-lime-*-*-*-*-*-*-*-*-*-*-iso10646-*"

if [ -f ~/.Xdefaults ] ; then
    xrdb -merge ~/.Xdefaults
fi

exec xmonad
