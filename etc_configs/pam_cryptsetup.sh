#!/bin/bash

CRYPT_USER="jimmieh"
DEVICE="/dev/nvme0n1p6"
MAPPER_NAME="home"

if [ "$PAM_USER" == "$CRYPT_USER" ] && [ ! -e /dev/mapper/$MAPPER_NAME ]
then
  tr '\0' '\n' | /usr/bin/cryptsetup open "$DEVICE" "$MAPPER_NAME"
fi
