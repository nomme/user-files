#!/bin/bash
INTERNAL_MONITOR="eDP-1"
DP1="DP-1-2-8"
DP2="DP-1-2-1-8"
HDMI1="HDMI-1"

# New dock
DP1="DP-1-1-1"
DP2="DP-1-1-8"

CONNECTED_MONITORS="$(xrandr | grep -E "\sconnected" | cut -d' ' -f1)"

function is_monitor()
{
    echo "$CONNECTED_MONITORS" | grep $1
}

if [ -n "$(is_monitor $DP1)" ] && [ -n "$(is_monitor $DP2)" ]
then
    #xrandr --output $DP1 --off
    #xrandr --output $DP2 --off
    #xrandr --output $INTERNAL_MONITOR --off
    #xrandr --output $DP1 --auto
    #sleep 3
    #xrandr --output $DP1 --auto --pos 0x280 --output $DP2 --auto --rotate left --pos 2560x0 --output $INTERNAL_MONITOR --off
    xrandr --output $INTERNAL_MONITOR --off --output $DP1 --auto --pos 0x120 --output $DP2 --auto --rotate right --pos 2560x0
    echo "Dual: $DP1, $DP2"
elif [ -n "$(is_monitor $DP1)" ] && [ -n "$(is_monitor $INTERNAL_MONITOR)" ]
then
    xrandr --output $DP1 --auto --output $INTERNAL_MONITOR --auto --left-of $DP1
    echo "Dual: $INTERNAL_MONITOR, $DP1"
elif [ -n "$(is_monitor $HDMI1)" ] && [ -n "$(is_monitor $INTERNAL_MONITOR)" ]
then
    xrandr --output $HDMI1 --auto --output $INTERNAL_MONITOR --auto --left-of $HDMI1
    echo "Dual: $INTERNAL_MONITOR, $HDMI1"
elif [ -n "$(is_monitor $DP1)" ]
then
    xrandr --output $DP1 --auto
    echo "Single: $DP1"
elif [ -n "$(is_monitor $HDMI1)" ]
then
    xrandr --output $HDMI1 --auto
    echo "Single: $HDMI1"
elif [ -n "$(is_monitor $INTERNAL_MONITOR)" ]
then
    xrandr --output $INTERNAL_MONITOR --auto --output $DP1 --off --output $DP2 --output $HDMI1 --off
    sleep 2
    xrandr --output $DP1 --off --output $DP2 --off --output $HDMI1 --off
    echo "Single: $INTERNAL_MONITOR"
fi

