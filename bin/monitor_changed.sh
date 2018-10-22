#!/usr/bin/bash
USERNAME="jimmieh"

LOCK_FILE="/tmp/monitor_changed.lock"

while [ -f $LOCK_FILE ]; do sleep 1; done
touch $LOCK_FILE
trap "rm -f $LOCK_FILE" EXIT

echo "$BASHPID $(date) monitor_changed running" >> /home/$USERNAME/tmp/udev.log
if [ -f /home/$USERNAME/local/bin/setmonitor.sh ]
then
    /home/$USERNAME/local/bin/setmonitor.sh 2>&1 >> /home/$USERNAME/tmp/udev.log
fi
echo "$BASHPID $(date) monitor_changed exiting" >> /home/$USERNAME/tmp/udev.log

