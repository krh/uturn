#!/bin/sh

top=/run/uturn
source $top/config.sh
result=$top/result.sh

export repo_path=$top/$repo
export build_path=$top/build
export install_path=$top/install
mkdir $build_path

/bin/time -o $result -f "build_time=%E" \
    bash -c "source $top/build-${repo}.sh; build"

if [ $? -eq 0 ]; then
    echo "status=success" >> $result
    echo success > $top/result-fifo
else
    echo "status=fail" >> $result
    echo fail > $top/result-fifo
fi

sudo poweroff
