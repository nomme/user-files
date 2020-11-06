#!/bin/bash

MIRRORS_DIR="/home/common/mirrors"
IHU_MIRROR="$MIRRORS_DIR/ihu"
SEM_MIRROR="$MIRRORS_DIR/sem"
SEM25_MIRROR="$MIRRORS_DIR/sem25"
REPO_TOOL="/home/jimmieh/local/android/repo"

# Setup:
# mkdir -p $MIRRORS_DIR/{ihu,sem}
# pushd $IHU_MIRROR
# repo init --mirror -u <IHU_repo> -b devel -m <manifest>
# popd
#
# pushd $SEM_MIRROR
# repo init --mirror -u <sem repo> -b master -m <manifest> --reference $IHU_MIRROR
# popd

function error()
{
    echo "$(basename $0) error: $@" >&2
    exit 1
}

[ -d "$IHU_MIRROR" ] || error "Could not find IHU mirror dir"
[ -d "$SEM_MIRROR" ] || error "Could not find SEM mirror dir"
[ -f $REPO_TOOL ] || error "Repo tool not found"

pushd $IHU_MIRROR
$REPO_TOOL sync
popd

pushd $SEM_MIRROR
$REPO_TOOL sync
popd

pushd $SEM25_MIRROR
$REPO_TOOL sync
popd
