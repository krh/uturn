#!/bin/sh

test -z $1 && { echo usage $0 SPEC; exit 1; }

source $1
path=$(readlink -f $name)

yum -y --releasever=$release --nogpg --installroot=$path	\
    --downloaddir=$PWD/rpms/fedora-20-x86_64			\
    --downloadonly						\
    --disablerepo='*'						\
    --enablerepo=fedora						\
    --enablerepo=updates					\
    install $rpms
