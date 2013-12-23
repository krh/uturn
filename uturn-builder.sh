#!/bin/sh

url=ssh://people.freedesktop.org/~krh

function build_repo {

    server_path=$1
    hash=$2
    fullref=$3

    repo=$(basename $server_path .git)
    ref=${fullref##*/}

    if [ -d repos/$repo.git ]; then
	git --git-dir=repos/$repo.git fetch origin $ref:$ref
    else
	git clone --bare $url/$repo repos/$repo.git
    fi

    container=containers/$repo
    test -d $container && sudo btrfs subvol del $container
    sudo btrfs subvolume snapshot fedora-20 $container

    state=builds/$repo-$ref
    rm -rf $state
    mkdir $state
    mkfifo $state/result-fifo
    git clone $url/$repo --reference=repos/$repo.git -b $ref $state/$repo
    echo -e "repo=$repo\nref=$ref\nhash=$hash" > $state/config.sh
    cp repos/build-$repo.sh $state

    echo "Starting nspawn builder"
    sudo systemd-nspawn -D $container --bind $PWD/$state:/run/uturn \
	--boot systemd.unit=uturn-builder.service  >$state/log.txt 2>&1 &

    cat $state/result-fifo | while read result; do
	source $state/result.sh
	echo "$repo $ref (${hash:0:8}) $status, build time $build_time" >uturn-bot-fifo
    done

    if [ $status = success ]; then
	# git --git-dir=repos/$repo.git push upstream $ref:$ref
    fi
}

ssh people.freedesktop.org ~/uturn-reader |
while read repo_path hash new_hash fullref; do
    build_repo $repo_path $new_hash $fullref &
done
