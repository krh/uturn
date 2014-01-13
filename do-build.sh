#!/bin/sh

top=/run/uturn
source $top/config.sh
result=$top/result.sh

repo_path=$top/$repo
build_path=$top/build
install_path=$top/install
mkdir $build_path

SECONDS=0
source $top/build-${repo}.sh

if build; then
    status=success
else
    status=fail
fi

TZ=UTC printf "status=$status\nbuild_time=%(%M:%S)T\n" $SECONDS \
    >$top/result-fifo

sudo poweroff
