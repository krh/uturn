#!/bin/sh

test -z $1 && { echo usage $0 SPEC; exit 1; }

function clean_up {
    btrfs subvolume delete $path
    exit
}

trap clean_up ERR INT

source $1
path=$(readlink -f $name)

test -d $path && { echo $path already exists; exit; }

btrfs subvolume create $path

yum -y --releasever=$release --nogpg --installroot=$path	\
    --downloaddir=$PWD/rpms/fedora-20-x86_64			\
    --disablerepo='*'						\
    -c rpms/fedora-20-x86_64/fedora.repo			\
    --enablerepo=local-fedora					\
    install $rpms

#    --enablerepo=fedora						\
#    --enablerepo=updates					\

cp uturn-builder.service $path/etc/systemd/system
cp uturn-config.site $path/usr/share/config.site
install  setup-container.sh $path/root
systemd-nspawn -D $path /root/setup-container.sh
install -g krh -o krh  do-build.sh $path/home/krh
