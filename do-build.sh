#!/bin/sh

top=/run/uturn
source $top/config.sh
result=$top/result.sh

export repo_path=$top/$repo
export build_path=$top/build
mkdir $build_path

/bin/time -o $result -f "build_time=%E" sh $top/build-${repo}.sh

if [ $? -eq 0 ]; then
    echo "status=success" >> $result
    echo success > $top/result-fifo
else
    echo "status=fail" >> $result
    echo fail > $top/result-fifo
fi

sudo poweroff
