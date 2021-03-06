#!/bin/bash

[ $(fastboot devices | wc -l) -eq 1 ] || { adb reboot bootloader; sleep 10; }
[ $(fastboot devices | wc -l) -eq 1 ] || { echo "No fastboot device found" >&2; exit 1; }

CMDLINE_IMG="$(mktemp)"
trap "rm -f $CMDLINE_IMG" EXIT

dd if=/dev/zero of="$CMDLINE_IMG" bs=1M count=1 iflag=fullblock
echo -en "loglevel=7\n" | dd of="$CMDLINE_IMG" conv=nocreat,notrunc

fastboot erase cmdline_a
fastboot flash cmdline_a "$CMDLINE_IMG"
fastboot reboot
