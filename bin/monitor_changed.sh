#!/usr/bin/bash
USERNAME="jimmieh"
echo "$BASHPID $(date) monitor_changed running" >> /home/$USERNAME/tmp/udev.log
if [ -f /home/$USERNAME/local/bin/setmonitor.sh ]
then
    /home/$USERNAME/local/bin/setmonitor.sh >> /home/$USERNAME/tmp/udev.log
fi
echo "$BASHPID $(date) monitor_changed exiting" >> /home/$USERNAME/tmp/udev.log

