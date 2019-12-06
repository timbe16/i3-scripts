#!/bin/bash

#set -e

## A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
lockNow=0
verbose=0
autolockAfterSec=300 # 5min
#autolockAfterSec=10 # for debug
autolockTimeInMs=$(($autolockAfterSec * 1000))

# configuration file for betterlockscreen

while getopts "h?vl" opt; do
    case "$opt" in
    h|\?)
        #show_help
        exit 0
        ;;
    v)  verbose=1
        ;;
    l)  lockNow=1
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

echo "verbose=$verbose, lockNow=$lockNow, autolockAfterSec=$autolockAfterSec, Leftovers: $@"


#
#
#
main() {
	# lock immediately or after idle
	[[ $lockNow = 1 ]] && runLocker || lockAfterIdle
}

#
#
#
lockAfterIdle() {
    while true
    do
		sleep 5
		
		isLockedVal="$(isLocked)"
        [[ $isLockedVal != "0" ]] && continue

        idleTime=`xprintidle`
        [[ $verbose = 1 ]] && echo "idleTime = $idleTime"
        
        remainTime=$((($autolockTimeInMs - $idleTime)/1000))
        remainTimeFormatted=`date -d@$remainTime -u +%M:%S`
        echo $remainTimeFormatted > /tmp/autolock
        #[ ${remain%?} -le 80 ] && echo -e "\n#FF8000" >> /tmp/autolock
        if [ "$remainTime" -lt 30 ];then
			echo -e "\n#FF8000" >> /tmp/autolock
		fi
		
        if (( $idleTime > $autolockTimeInMs )); then
            runLocker
            
        fi
    done
}

#
#
#
isLocked() {
	local funcResult=`pgrep i3lock | wc -l` 
	echo "$funcResult"
}

#
#
#
getCurrentLayout() {
	 local funcResult=`~/git/xkb-switch/build/xkb-switch -p`
	 echo "$funcResult"
}

#
#
#
getCurrentLayout2() {
	 local funcResult=`dbus-send --dest=ru.gentoo.KbddService --print-reply=literal /ru/gentoo/KbddService ru.gentoo.kbdd.getCurrentLayout | cut -d " " -f 5`
	 [[ $funcResult = 0 ]] && echo "us" || echo "ru"
}


#
#
#
swithLayoutToUs() {
	 #`~/git/xkb-switch/build/xkb-switch -n`
	 `dbus-send --dest=ru.gentoo.KbddService /ru/gentoo/KbddService ru.gentoo.kbdd.next_layout`
}

#
#
#
runLocker() {
	[[ $verbose = 1 ]] && echo "locking now ..";
	#runSimpleLocker
	runColorLocker
}

#
#
#
runSimpleLocker() {
	i3lock --color 475263 -f
}

#
#
#
runColorLocker() {
    insidecolor="#00000000"
    ringcolor="#ffffffff"
    keyhlcolor="#d23c3dff"
    bshlcolor="#d23c3dff"
    separatorcolor="#00000000"
    insidevercolor="#00000000"
    insidewrongcolor="#d23c3dff"
    ringvercolor="#ffffffff"
    ringwrongcolor="#ffffffff"
    verifcolor="#ffffffff"
    timecolor="#ffffffff"
    datecolor="#ffffffff"
    loginbox="#00000066"
    font="System San Francisco Display"
    locktext='Type password to unlock...'
    lock_timeout=5
    
    currentLayout="$(getCurrentLayout2)"
	echo "currentLayout = $currentLayout"
	
    [[ $currentLayout != "us" ]] && swithLayoutToUs
    
    currentLayout="$(getCurrentLayout2)"
	echo "currentLayout = $currentLayout"

    B='#00000000'  # blank
    C='#ffffff22'  # clear ish
    D='#ff00ffcc'  # default
    T='#ee00eeee'  # text
    W='#880000bb'  # wrong
    V='#bb00bbbb'  # verifying
    S='70'  # font size
    S2='40'  # font size 2
    S3='20'  # font size 3
    keylayout=`~/git/xkblayout-state/xkblayout-state print "%s"`

    ~/git/i3lock-color/build/i3lock \
    --insidevercolor=$C   \
    --ringvercolor=$V     \
    \
    --insidewrongcolor=$C \
    --ringwrongcolor=$W   \
    \
    --insidecolor=$B      \
    --ringcolor=$D        \
    --linecolor=$B        \
    --separatorcolor=$D   \
    \
    --verifcolor=$T        \
    --wrongcolor=$T        \
    --timecolor=$T        \
    --datecolor=$T        \
    --layoutcolor=$T      \
    --keyhlcolor=$W       \
    --bshlcolor=$W        \
    \
    --screen 1            \
    --blur 5              \
    --clock               \
    --indicator           \
    --timestr="%H:%M:%S"  \
    --datestr="%A, %d %B %Y" \
    \
    --radius=200 \
    --ring-width=4 \
    --bar-indicator \
    \
    --time-font="$font" \
    --date-font="$font" \
    --layout-font="$font" \
    --verif-font="$font" \
    --wrong-font="$font" \
    --datepos='x+1150:y+700' \
    \
     --veriftext="unlocking ..." \
     --wrongtext="Nope!" \
     --timesize=$S \
     --datesize=$S2 \
     --layoutsize=$S3 \
     --verifsize=$S \
     --wrongsize=$S \
     --greetersize=$S \
     --modsize=10
}

main
