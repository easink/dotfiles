#!/usr/bin/env zsh

typeset -A DISKS
###
# Config
###
DATE_FORMAT="%d-%m-%Y %H:%M:%S"
TIME_ZONES=("Europe/Stockholm")
DISKS=(hda1 /)

SEPERATOR=' ^fg(#86AA3F)^c(3)^fg() '
BAR_BG='#7DA926'
BAR_FG='#B9D56E'
BAR_HH=6
BAR_HW=40
BAR_VH=12
BAR_VW=3
BAR_ARGS="-bg $BAR_BG -fg $BAR_FG -w $BAR_HW -h $BAR_HH"
COL_NORM=${BAR_FG}
COL_WARN='#ff9800'
COL_CRIT='#ff4747'
ICON_DIR="${HOME}/.share/icons/dzen"
NETWORK_INTERFACE=eth1
NET_DOWN_MAX=55
NET_UP_MAX=14
WLANIF=wlp58s0
MAILDIR=~/mail/GmailMain

# Battery config
BAT_FILEBASE="/sys/class/power_supply/BAT0/charge"
BAT_FULL=$(<${BAT_FILEBASE}_full) # battery charged full
BAT_LOW=25                        # percentage of battery life marked as low
BAT_LOWCOL=${COL_WARN}            # color when battery is low
BAT_CRIT=5                        # percentage of battery life marked as critical
BAT_CRITCOL=${COL_CRIT}           # color when battery is critical

# CPU config
# CPU_BASE="/sys/devices/platform/coretemp.0/hwmon/hwmon*/temp2_"
# CPU_BASE=$(find /sys/devices/platform/coretemp.0/hwmon | grep _input$ | tail -1 | sed 's/input$//')
CPU_BASE=$(echo /sys/devices/platform/coretemp.0/**/*_input([1]:s/_input/_/))
CPU_INPUT=${CPU_BASE}"input"
CPU_WARN=$(<$CPU_BASE"max")
CPU_CRIT=$(<$CPU_BASE"crit")

# Volume config
VOLCTRL="Master,0"
VOLINC_CMD="amixer -c0 sset $VOLCTRL 5dB+ >/dev/null"
VOLDEC_CMD="amixer -c0 sset $VOLCTRL 5dB- >/dev/null"
#VOLMAX=$(amixer -c0 get $VOLCTRL | awk '/^  Limits/ { print $5 }')
#VOLMAX=100
#VOLCUR="amixer -c0 get PCM | awk '/^  Front Left/ { print \$4 \" \" $VOLMAX }'"

# Verification
## CPU
[[ $CPU_CRIT -gt 0 ]] || echo "[E] CPU function error!" || exit
## BATTERY
[[ $BAT_FULL -gt 0 ]] || echo "[E] Battery function error!" || exit

#GLOBALIVAL=1m
# Main loop interval in seconds
INTERVAL=1

# function calling intervals in seconds
DATEIVAL=1
#TIMEIVAL=1
DISKIVAL=60
CPUTEMPIVAL=5
CPUIVAL=2
#NPIVAL=3
NETIVAL=1
WNETIVAL=30
BATIVAL=10
VOLIVAL=1

###
# Functions
###
fdate()
{
    date +${DATE_FORMAT}
}

fgtime()
{
    local zone
    print_space=0
    for zone in $TIME_ZONES; do
        [[ $print_space -eq 1 ]] && print -n " "
        print -n "$(TZ=$zone date '+%H:%M')"
        print_space=1
    done
}

#
# Format: label1 mountpoint1 label2 mountpoint2 ... labelN mountpointN
# Copied and modified from Rob
fdisk() {
    local rstr tstr i sep
    for i in ${(k)DISKS}; do
        tstr=$(print `df -h $DISKS[$i]|sed -ne 's/^.* \([0-9]*\)% .*/\1/p'` 100 | \
            gdbar -h $BAR_HH -w $BAR_HW -fg $BAR_FG -bg $BAR_BG -l "${i}" -nonl | \
            sed 's/[0-9]\+%//g;s/  / /g')
        if [ ! -z "$rstr" ]; then
            sep=${SEPERATOR}
        fi
        rstr="${rstr}${sep}${tstr}"
    done
    print -n $rstr
}

# Requires mesure
# or /proc/net/dev
fnet() {
    local up down
    up=$(mesure -K -l -c 3 -t -o $NETWORK_INTERFACE)
    down=$(mesure -K -l -c 3 -t -i $NETWORK_INTERFACE)
    echo "$down $up"
}

fwnet()
{
    if [[ $(cat /sys/class/net/$WLANIF/carrier) -eq 1 ]]; then
        percent=$(iwconfig $WLANIF|awk -F "[ =/]*" '/Link/{printf "%d", $4*100/$5}')
#       if   [ $percent -ge 75 ]; then print -n "^i(${ICON_DIR}/wlan_signal_full.xbm)"
#       elif [ $percent -ge 50 ]; then print -n "^i(${ICON_DIR}/wlan_signal_mid.xbm)"
#       elif [ $percent -ge 25 ]; then print -n "^i(${ICON_DIR}/wlan_signal_low.xbm)"
#       else                           print -n "^i(${ICON_DIR}/wlan_signal_nil.xbm)"
#       fi
        print "${percent}%"
    else
        print "[No carrier]"
    fi
}

fcputemp()
{
    local temp color

    color=$COL_NORM
    temp=$(<$CPU_INPUT)
    # print -n ${(@)$(</sys/class/thermal/thermal_zone0/temp)[2,3]}
    if [[ $temp -ge $CPU_WARN ]]; then
        color=$COL_WARN
        [[ $temp -ge $CPU_CRIT ]] && color=$COL_CRIT
        print -n "^fg($color)$(($temp / 1000))^fg()°C"
    fi
}

#np()
#{
#    #MAXPOS="100"
#    CAPTION="^i(${ICON_DIR}/musicS.xbm)"
#    #POS=`mpc | sed -ne 's/^.*(\([0-9]*\)%).*$/\1/p'`
#    #POSM="$POS $MAXPOS"
#    print -n "$CAPTION "
#    mpc | head -n1 | tr -d '\n'
#    #echo "$POSM" | gdbar -h 7 -w 50 -fg $BAR_FG -bg $BAR_BG
#}

fcpu()
{
    print -n "^i(${ICON_DIR}/cpu2.xpm)"
    gcpubar -c 2 -bg $BAR_BG -fg $BAR_FG -w $BAR_HW -h $BAR_HH | tail -n1 | tr -d '\n'
}

fmail() {
    find ${MAILDIR}/*/new -not -type d | wc -l
}

fbattery() {
    local ac_online bat_now bat_perc color

    ac_online=$(</sys/class/power_supply/AC/online)
    bat_now=$(<${BAT_FILEBASE}_now)   # battery charge status
    bat_perc=$(($bat_now * 100 / $BAT_FULL))
    color=$BAR_FG
    if [[ $ac_online -eq 1 ]]; then
        # AC online
        print -n "^i(${ICON_DIR}/battery_ac.xpm)"
        if [[ $bat_perc -lt 100 ]]; then print -n " ${bat_perc}%"; fi
    else
        # AC offline, using battery
        print -n "^i(${ICON_DIR}/battery.xbm)"
        if [[ $bat_perc -lt $BAT_LOW ]]; then
            color=$BAT_LOWCOL
            [[ $bat_perc -le $BAT_CRIT ]] && color=$BAT_CRITCOL
            print -n "^fg($COL_WARN)${bat_perc}^fg()%"
        fi
        print $bat_perc | gdbar -h $BAR_HH -w $BAR_HW -fg $color -bg $BAR_BG
    fi
}

#VOLCUR=0
fvolume() {
    VOLCUR=$(amixer -c0 get $VOLCTRL | awk '/^  Mono/{print $4}' | tr -d '[]')
#    VOLCUR=$(($VOLCUR*100/$VOLMAX))
#    VOLCUR=$(($VOLCUR+1))
    print -n "^i(${ICON_DIR}/volume.xbm)"
#    print -n " ${VOLCUR} "
    print $VOLCUR | gdbar -h $BAR_HH -w $BAR_HW -fg $BAR_FG -bg $BAR_BG
#    print $VOLCUR
}

DATEI=$DATEIVAL
#TIMEI=$
DISKI=$DISKIVAL
#NPI=0
CPUTEMPI=$CPUTEMPIVAL
CPUI=$CPUIVAL
#NETI=$NETIVAL
WNETI=$WNETIVAL
BATI=$BATIVAL
#VOLI=$VOLIVAL

#date=$(_date)
#times=$(_time)
#disk_usage=$(get_disk_usage)
##now_playing=$(np)
#temp=$(cpu_temp)
#cpumeter=$(cpu)
##net_rates=( `get_net_rates` )

while true; do
    [[ $DATEI -ge $DATEIVAL ]] && PDATE=$(fdate) && DATEI=0
    [[ $DISKI -ge $DISKVAL ]] && PDISK=$(fdisk) && DISKI=0
    #[[ $NPI -ge $NPIVAL ]] && PNP=$(np) && NPI=0
    [[ $CPUI -ge $CPUIVAL ]] && PCPU=$(fcpu) && CPUI=0
    [[ $CPUTEMPI -ge $CPUTEMPIVAL ]] && PCPUTEMP=$(fcputemp) && CPUTEMPI=0
    #[[ $NETI -ge $NETIVAL ]] && PNET=( `get_net_rates` ) && NETI=0
    [[ $WNETI -ge $WNETIVAL ]] && PWNET=$(fwnet) && WNETI=0
    [[ $BATI -ge $BATIVAL ]] && PBAT=$(fbattery) && BATI=0
    #[[ $VOLI -ge $VOLIVAL ]] && PVOL=$(fvolume) && VOLI=0

    # Disk usage
#    echo -n "${disk_usage}${SEPERATOR}"
#    # Network
#    echo $net_rates[1] | gdbar -nonl -s v -w $BAR_VW -h $BAR_VH -min 0 \
#        -max $NET_DOWN_MAX -fg $BAR_FG -bg $BAR_BG
#    echo -n " "
#    echo $net_rates[2] | gdbar -nonl -s v -w $BAR_VW -h $BAR_VH -min 0 \
#        -max $NET_UP_MAX -fg $BAR_FG -bg $BAR_BG
#    echo -n "${SEPERATOR}"
#    # Mail notification
#    if [ `has_new_mail` -gt 0 ]; then
#        echo -n "^fg(#73d216)"
#    fi
#    echo -n "^i(${ICON_DIR}/envelope2.xbm)^fg()${SEPERATOR}"

    # Disk usage
    print -n ${PDISK}${SEPERATOR}

    # Cpu temp
    #print -n "^i(${ICON_DIR}/cpu.xpm)"
    print -n ${PCPU}
    print -n ${PCPUTEMP}${SEPERATOR}

    # Battery
    print -n ${PBAT}${SEPERATOR}

    # Volume
    #print -n ${PVOL}${SEPERATOR}

    # Wlan
    print -n ${PWNET}${SEPERATOR}

    # Time and date
    #echo -n "${times}${SEPERATOR}"
    print "${PDATE}"

    DATEI=$(($DATEI+1))
    #TIMEI=$(($TIMEI+1))
    DISKI=$(($DISKI+1))
    #NPI=$(($NPI+1))
    CPUI=$(($CPUI+1))
    CPUTEMPI=$(($CPUTEMPI+1))
    #NETI=$(($NETI+1))
    WNETI=$(($WNETI+1))
    BATI=$(($BATI+1))
    #VOLI=$(($VOLI+1))

    sleep $INTERVAL
done
