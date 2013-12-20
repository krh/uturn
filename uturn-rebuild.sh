#!/bin/sh

ref=${2?master}

cd $1

git show-ref $2 | while read hash fullref; do
	echo $hash $hash $fullref | ../uturn-post-receive
done
