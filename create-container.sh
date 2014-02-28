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

# yum will use the vars from the install root
mkdir -p $path/etc/yum/vars/
echo $basearch > $path/etc/yum/vars/basearch
echo $arch > $path/etc/yum/vars/arch

# create a local yum repo configuration to be used by install
cat << EOF > local.$repo-$release-$arch.repo
[local]
name=Local Repo
baseurl=file://$PWD/rpms/$repo-$release-$arch
EOF

uturnpath=$(readlink -f $(dirname $0))

case $1 in
    download)
	yumdownloader -y --releasever=$release --installroot=$path	\
	    --destdir=$PWD/rpms/$repo-$release-$arch			\
	    --disablerepo='*'						\
	    --enablerepo=fedora						\
	    --enablerepo=updates					\
	    --resolve							\
	    $rpms

	createrepo -o rpms/$repo-$release-$arch rpms/$repo-$release-$arch
	;;

    install)
	yum -y --releasever=$release --nogpg --installroot=$path	\
	    --downloaddir=$PWD/rpms/$repo-$release-$arch		\
	    --disablerepo='*'						\
	    -c local.$repo-$release-$arch.repo --enablerepo=local	\
	    install $rpms

	cp $uturnpath/uturn-builder.service $path/etc/systemd/system
	cp $uturnpath/uturn-config.site $path/usr/share/config.site
	install $uturnpath/setup-container.sh $path/root
	install -D $uturnpath/do-build.sh $path/lib/uturn/do-build.sh
	systemd-nspawn -D $path /root/setup-container.sh
	;;

    *)
	echo "Unknown command: $1"
	;;
esac
