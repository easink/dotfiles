
PATH=$PATH:/usr/sbin

SHELL=/bin/bash
LC_CTYPE=sv_SE.UTF-8; export LC_CTYPE
FONT="-*-lime-*-*-*-*-*-*-*-*-*-*-iso10646-*"

if [ -f ~/.Xdefaults ] ; then
    xrdb -merge ~/.Xdefaults
fi

stalonetray -i 16 --max-width 48 --icon-gravity E --geometry 48x16-0+0 -bg '#2e3436' --sticky --skip-taskbar &
~/bin/dzen.sh | dzen2 -e 'onstart=lower' -p -ta r -fn '-*-terminus-medium-*-*-*-12-*-*-*-*-*-iso8859-1' -bg '#2e3436' -fg '#babdb6' -h 16 -w 1232 &
# width 1632

exec xmonad
