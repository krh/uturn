#!/bin/sh

test -z "$1" -o -z "$2" && { echo "usage $0 [download|install] SPEC"; exit 1; }

function clean_up {
    sudo btrfs subvolume delete $path
    exit
}

trap clean_up ERR INT

source $2
path=$(readlink -f $name)

test -d $path || btrfs subvolume create $path

case $1 in
    download)
	yumdownloader -y --releasever=$release --installroot=$path	\
	    --destdir=$PWD/rpms/fedora-20-x86_64			\
	    --disablerepo='*'						\
	    --enablerepo=fedora						\
	    --enablerepo=updates					\
	    --resolve							\
	    $rpms

	createrepo -o rpms/fedora-20-x86_64 rpms/fedora-20-x86_64
	;;

    install)
	yum -y --releasever=$release --nogpg --installroot=$path	\
	    --downloaddir=$PWD/rpms/fedora-20-x86_64			\
	    --disablerepo='*'						\
	    -c local.repo --enablerepo=local				\
	    install $rpms

	cp uturn-builder.service $path/etc/systemd/system
	cp uturn-config.site $path/usr/share/config.site
	install  setup-container.sh $path/root
	install -D do-build.sh $path/lib/uturn/do-build.sh
	systemd-nspawn -D $path /root/setup-container.sh
	;;

    *)
	echo "Unknown command: $1"
	;;
esac
