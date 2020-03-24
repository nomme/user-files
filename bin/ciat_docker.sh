#/bin/bash

UNIT_NAME="device.my_ihu"
function error()
{
  echo "Error: $@" >&2
  exit -1
}

[ -f /tmp/one_update_flashfiles/fastboot.sh ] || error "No fastboot.sh file found"

docker run \
    --user=1003:1003 \
    --group-add 987 \
    --rm \
    -ti \
    --privileged \
    -e UNIT_NAME=$UNIT_NAME \
    -e CONFIG_FILE=/oneupdate/nodes.config \
    --group-add dialout \
    -v /etc/localtime:/etc/localtime \
    -v /dev/serial:/dev/serial \
    -v $AOSP_HOME/vendor/aptiv/one_update:/oneupdate/one_update \
    -v $HOME/repos/android_ciat-testrig/rigconfig/ciat_nodes.config:/oneupdate/nodes.config:ro  \
    -v /tmp/one_update_flashfiles:/oneupdate/flashfiles \
    -v /run/udev:/run/udev:ro \
    -v /dev:/dev \
    --mount type=bind,source=/dev/bus/usb,target=/dev/bus/usb \
    -w /tmp \
    "$DOCKER_CIAT_SWDL" \
    $@

    #/oneupdate/one_update/ciat/ciat_ihu_update_one.py --flashfiles /oneupdate/flashfiles --config-file /oneupdate/nodes.config --config-unit $UNIT_NAME
