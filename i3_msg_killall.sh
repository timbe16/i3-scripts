#!/bin/bash


i3-msg [class="."] kill
sleep 3
counter=`wmctrl -l | wc -l`
echo $counter
notify-send $counter
[[ $counter != "0" ]] && exit 1

exit 0
