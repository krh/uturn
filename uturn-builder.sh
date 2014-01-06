#!/bin/sh

url=ssh://people.freedesktop.org/~krh

function build_repo {

    server_path=$1
    hash=$2
    fullref=$3

    repo=$(basename $server_path .git)
    ref=${fullref##*/}

    if [ -d repos/$repo.git ]; then
	git --git-dir=repos/$repo.git fetch origin +$ref:$ref
    else
	git clone --bare $url/$repo repos/$repo.git
    fi

    source ./build-$repo.sh
    build_container=containers/$repo
    test -d $build_container && sudo btrfs subvol del $build_container
    sudo btrfs subvolume snapshot $container $build_container

    state=builds/$repo-$ref
    rm -rf $state
    mkdir $state
    mkfifo $state/result-fifo
    git clone $url/$repo --reference=repos/$repo.git -b $ref $state/$repo
    echo -e "repo=$repo\nref=$ref\nhash=$hash" > $state/config.sh
    cp build-$repo.sh $state

    for d in $deps; do
	echo "Installing build dep $d"
	sudo cp -an $PWD/builds/$d-master/install/. $build_container
    done

    echo "Starting nspawn builder"
    sudo systemd-nspawn -D $build_container --bind $PWD/$state:/run/uturn \
	--boot systemd.unit=uturn-builder.service  >>$state/log.txt 2>&1 &

    read result <$state/result-fifo
    source $state/result.sh
    echo "$repo $ref (${hash:0:8}) $status, build time $build_time" >uturn-bot-fifo

    echo "status: $status, upstream: $upstream"
    if [ $status = success -a x$upstream != x ]; then
	echo "attempting push"
	git --git-dir=repos/$repo.git push $upstream $ref
    fi
}

case $1 in
    daemon)
	ssh people.freedesktop.org ~/uturn-reader |
	while read repo_path hash new_hash fullref; do
	    build_repo $repo_path $new_hash $fullref &
	done
	;;

    rebuild)
	build_repo $2 dummyhash ${3:-master}
	;;

    debug)
	repo=$2
	ref=${3:-master}
	state=builds/$repo-$ref
	build_container=containers/$repo
	sudo systemd-nspawn -D $build_container --bind $PWD/$state:/run/uturn \
	    --boot systemd.unit=multi-user.target
	;;

    *)
	echo "usage:"
	echo "  uturn-builder.sh rebuild REPO [BRANCH]"
	echo "        reubuild BRANCH of REPO, defaulting to master"
	echo
	echo "  uturn-builder.sh daemon"
	echo "        start build daemon"
esac
