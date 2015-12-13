#!/bin/zsh

if [ "$OSTYPE" = "darwin11" ]; then
    # row from /opt/X11/bin/startx
    sysclientrc=/opt/X11/lib/X11/xinit/xinitrc
    source $sysclientrc
fi

PATH=$PATH:/usr/sbin

SHELL=/bin/zsh; export SHELL
LC_CTYPE=en_US.UTF-8; export LC_CTYPE
FONT="-*-lime-*-*-*-*-*-*-*-*-*-*-iso10646-*"

#[[ -f ~/.xmodmap-$(uname -n) ]] && xmodmap ~/.xmodmap-$(uname -n) || xmodmap ~/.xmodmap-default
#[[ -f ~/.Xdefaults ]] && xrdb -merge ~/.Xdefaults
setxkbmap -layout 'us(intl)'
xmodmap ~/.xmodmap-default
xrdb -merge ~/.Xdefaults

stalonetray -i 16 --icon-gravity E --geometry 3x1-0+0 -bg '#2e3436' --sticky --skip-taskbar &
~/bin/dzen.sh | dzen2 -e 'onstart=lower' -p -ta r -fn '-*-terminus-medium-*-*-*-12-*-*-*-*-*-iso8859-1' -bg '#2e3436' -fg '#babdb6' -h 16 -w 1232 &
# width 1632

exec xmonad
