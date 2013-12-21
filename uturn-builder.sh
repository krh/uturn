#!/bin/sh

url=ssh://people.freedesktop.org/~krh

function build_repo {

    server_path=$1
    hash=$2
    fullref=$3

    repo=$(basename $server_path .git)
    ref=${fullref##*/}

    echo '***' updating local ${repo} repo
    if [ -d $repo.git ]; then
	git --git-dir=repos/$repo.git fetch origin $ref:$ref
    else
	git clone --bare $url/$repo repos/$repo.git
    fi

    container=containers/$repo
#    test -d $container && sudo btrfs subvol del $container
#    sudo btrfs subvolume snapshot /root/fedora-20-x86_64 $container

    state=build-$$
    mkdir $state
    mkfifo $state/result-fifo
    git clone $url/$repo --reference=repos/$repo.git -b $ref $state/$repo
    echo -e "repo=$repo\nref=$ref\ntop=/home/krh\n" > $state/config.sh
    cp repos/build-$repo.sh $state

    sudo systemd-nspawn -D $container --bind $PWD/$state:/run/uturn \
	--boot systemd.unit=uturn-builder.service &

    echo "--- waiting for container to finish"
    cat $state/result-fifo | while read result; do
	echo "--- got $result from pipe"
	case $result in
	    success) echo success ;;
	    fail) echo fail ;;
	esac
    done
	
}

ssh people.freedesktop.org ~/uturn-reader |
while read repo_path hash new_hash fullref; do
    build_repo $repo_path $new_hash $fullref &
done
