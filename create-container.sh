#!/bin/sh

# path=$PWD/fedora-20-i386
# repo=fedora-i386

path=$(readlink -f $1)
repo=fedora

btrfs subvolume create $path

yum -y --releasever=20 --nogpg --installroot=$path \
    --disablerepo='*'  --enablerepo=$repo install \
    systemd passwd yum fedora-release vim-minimal sudo file \
    openssh-clients \
    libtool automake autoconf git make \
    libffi-devel expat-devel doxygen

cp uturn-builder.service $path//etc/systemd/system
cp do-build.sh $path/root
cp setup-container.sh $path/root
chmod 700 $path/root/setup-container.sh
systemd-nspawn -D $path /root/setup-container.sh


# boot with audit=0
# use --bind=<uturn workdir> to bind into container?
#
# more rpms: gdb, emacs, strace...
#
# weston rpms: mesa-libEGL-devel mesa-libGLES-devel cairo-devel
#   libwayland-egl-devel libXcursor-devel systemd-devel mesa-libgbm-devel
#   mtdev-devel libxkbcommon-devel libjpeg-turbo-devel pam-devel
#   diffutils (for cmp use in Makefile)
