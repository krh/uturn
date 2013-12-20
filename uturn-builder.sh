#!/bin/sh

url=ssh://people.freedesktop.org/~krh

function build_autotools_repo {
    mkdir uturn-build
    cd uturn-build
    NOCONFIGURE=1 ../autogen.sh --prefix=/usr
    test -f Makefile || ../configure --prefix=/usr
    make -j5
}

function build_repo {
    repo=$1
    hash=$2
    ref=$3
    path=$repo--$ref

    echo '***' updating local ${repo} repo
    if [ -d cache/$repo.git ]; then
	git --git-dir=cache/$repo.git fetch origin $ref:$ref
    else
	git clone --bare $url/$repo cache/$repo.git
    fi

    rm -rf $path
 
    echo '***' cloning ${repo} for build
    git clone $url/$repo --reference=cache/$repo.git $path -b $ref

    pushd $path
    if test -f ../build-${repo}.sh; then
	echo '***' using build-${repo}.sh build recipe
	source ../build-${repo}.sh;
    else
	echo '***' falling back to generic autotools build recipe
	build_autotools_repo
    fi

    if [ $? -eq 0 ]; then
	echo '***' Build of $repo, branch $ref: SUCCESS
    else
	echo '***' Build of $repo, branch $ref: FAIL
    fi

    popd
    # rm -rf $path
}

function update_repo {
    server_path=$1
    hash=$2
    full_ref=$3

    repo=$(basename $server_path .git)
    ref=${fullref##*/}

    echo "building $repo, branch $ref ($hash)"

    build_repo $repo $hash $ref # >$repo--$ref.log 2>&1 &
}

ssh people.freedesktop.org ~/uturn-reader |
while read repo_path hash new_hash fullref; do
    update_repo $repo_path $new_hash $fullref
done
