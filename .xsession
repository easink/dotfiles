#!/bin/bash
# Execute enlightenment. ALWAYS make sure this is at the end of this
# startup file - and ALWAYS run things before it with an & at the end.
# For example:
#   xterm &
#   kpanel &
# It is suggested to use Enlightenment's Remember dialog for having apps
# spawned automatically on login.

# Fix AntiAliasing for GDK
#export GDK_USE_XFT=1
# Fix AntiAliasing for KDE/QT
#export QT_XFT=true

xrandr -o left

SHELL=$(awk -F: '/^andreas:/{print $7}' /etc/passwd); export SHELL
PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin; export PATH
LC_CTYPE=sv_SE.UTF-8; export LC_CTYPE
#PRINTER=lp@10.10.11.31
#FONT="-*-clean-*-*-*-*-*-*-*-*-*-*-*-*"
FONT="-misc-fixed-*-*-*-*-8-*-*-*-*-*-iso10646-*"

xrdb ~/.Xdefaults
xmodmap ~/.xmodmap

# Set background color
xsetroot -solid black

urxvtd -q -o -f

#
urxvtc
urxvtc

#xscreensaver-command -exit
#xscreensaver -no-splash &
#unclutter &

# max 255 i bredd för xrootconsole
#(sleep 8;tail --retry -qf /var/log/auth.log /var/log/syslog | xrootconsole -geometry 200x25+0+0 --wrap)&
#(sleep 8;tail -qf /var/log/auth.log /var/log/syslog | xrootconsole -geometry 200x25+0+0 --wrap)&
#xv -quit -max -root /usr/share/enlightenment/themes/BrushedMetal-Tigert/backgrounds/images/turquoise_treemoon.jpg

#mkfifo /tmp/port8888
#(tail -q --retry --follow=name /var/log/auth.log /var/log/syslog | xrootconsole -geometry 213x10+0+894 --wrap)&
#(tail -q --follow=name /var/log/local0 | xrootconsole -geometry 200x1+0+0)&

#Esetroot -scale ~/images/mozilla1280.bmp

#root-tail -g 255x13+0+894 -font -*-lime-*-*-*-*-*-*-*-*-*-*-*-* -no-filename /var/log/auth.log /var/log/syslog &
#gkrellm &


#iceweasel &
my.chromium.sh &

#google-chrome --proxy-pac-url=http://wpad.fra.se/wpad.dat &

#xterm -geometry 80x67+302+-2 &
#xterm -geometry 80x67+790+-2 &
#xterm -geometry 80x67+302+1022 &
#xterm -geometry 80x67+790+1022 &
#xterm -e "wmiir read /events"

#exec /usr/bin/X11/xterm
#exec /usr/bin/wmii
#exec /usr/local/bin/wmii

/usr/bin/root-tail -f -g 1200x140+0+1460 -no-filename -font $FONT /var/log/messages

#stalonetray -i 16 --max-width 48 --icon-gravity E --geometry 48x16-0+0 -bg '#2e3436' --sticky
~/bin/dzen.sh | dzen2 -e 'onstart=lower' -p -ta r -fn '-*-terminus-medium-*-*-*-12-*-*-*-*-*-iso8859-1' -bg '#2e3436' -fg '#babdb6' -h 16 &
exec /usr/bin/xmonad


#FONT="-artwiz-lime-*-*-*-*-*-*-*-*-*-*-*-*"

# Start URxvt daemon so we can quickly open the other clients
#urxvtd -q -o -f
#[ -x "/usr/bin/numlockx" ] && numlockx &
#[ -x "/usr/bin/unclutter" -a -z "`pidof unclutter`" ] && \
#	unclutter -idle 5 -root&

# Set mouse cursor and background colour
#xsetroot -cursor_name left_ptr -solid '#090909' &

#/usr/bin/gkrellm -g 68x675+0+16 --wm &


# | dzen2 -ta r -fg "#a8a3f7" -bg "#3f3c6d" &
#tail -f /var/log/messages | dzen2 -fn $FONT -l 20 -x 100 -w 500 &
#tail -f /var/log/messages | dzen2 -l 20 &

#/usr/bin/root-tail -f -g 960x140+0+1060 -no-filename -font $FONT /var/log/smail/{logfile,paniclog}
#/usr/bin/root-tail -f -g 960x140+960+1060 -no-filename -font $FONT /var/log/{auth.log,messages}


#stalonetray &
#/usr/bin/stalonetray -i 16 --max-width 48 --icon-gravity E --geometry 48x16-0+0 -bg '#2e3436' --sticky --skip-taskbar &
#~/bin/dzen.sh | dzen2 -e 'onstart=lower' -p -ta r -fn '-*-terminus-medium-*-*-*-12-*-*-*-*-*-iso8859-1' -bg '#2e3436' -fg '#babdb6' -h 16 -w 1632 &

