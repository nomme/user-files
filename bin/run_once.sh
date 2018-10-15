#/usr/bin/env bash

function run_it()
{
    if [ -z "$(pgrep $1)" ]
    then
        $@ &
    fi
}

run_it chromium --restore-last-session
run_it pidgin
run_it nm-applet
run_it zim
#run_it pasystray
