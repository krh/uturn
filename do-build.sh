#!/bin/sh

source /run/uturn/config.sh
repo_path=$top/$repo

build_path=$top/build
mkdir $build_path
source /run/uturn/build-${repo}.sh

if [ $? -eq 0 ]; then
    echo '***' Build of $repo, branch $ref: SUCCESS
    echo success > /run/uturn/result-fifo
else
    echo '***' Build of $repo, branch $ref: FAIL
    echo fail > /run/uturn/result-fifo
fi

sudo poweroff
