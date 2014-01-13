#!/bin/sh

url=ssh://people.freedesktop.org/~krh

function close_bugs {
    local repo=$1
    local old_hash=$2
    local new_hash=$3

    git --git-dir=repos/$repo.git rev-list $new_hash ^$old_hash |
    while read rev; do
	bug = $(git --git-dir=repos/$repo.git show --no-patch --format=%s $rev | grep "Closes: https://bugs.freedesktop")
	echo $bug
    done
}

function build_repo {

    server_path=$1
    hash=$2
    fullref=$3

    repo=$(basename $server_path .git)
    ref=${fullref##*/}

    echo "building $repo, branch $ref"

    if [ -d repos/$repo.git ]; then
	git --git-dir=repos/$repo.git fetch -q origin +$ref:$ref
    else
	git clone -q --bare $url/$repo repos/$repo.git
    fi

    source ./build-$repo.sh
    build_container=containers/$repo
    test -d $build_container && \
	sudo btrfs subvol del $build_container >/dev/null
    sudo btrfs subvolume snapshot $container $build_container >/dev/null

    state=builds/$repo-$ref
    rm -rf $state
    mkdir $state
    mkfifo $state/result-fifo
    git clone -q $url/$repo --reference=repos/$repo.git -b $ref $state/$repo
    echo -e "repo=$repo\nref=$ref\nhash=$hash" > $state/config.sh
    cp build-$repo.sh $state

    for d in $deps; do
	sudo cp -an $PWD/builds/$d-master/install/. $build_container
    done

    sudo systemd-nspawn -D $build_container --bind $PWD/$state:/run/uturn \
	--boot systemd.unit=uturn-builder.service  >>$state/log.txt 2>&1 &

    source $state/result-fifo
    echo "status: $status, build_time: $build_time"

    if [ "$status" = success ]; then
	test -n "$upstream" && \
	    git --git-dir=repos/$repo.git push $upstream $ref
    else
	echo "krh: build failed"
    fi

    test "$status" = success
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

    close)
	close_bugs $2 $3 $4
	;;

    *)
	echo "usage:"
	echo "  uturn-builder.sh rebuild REPO [BRANCH]"
	echo "        reubuild BRANCH of REPO, defaulting to master"
	echo
	echo "  uturn-builder.sh daemon"
	echo "        start build daemon"
esac
