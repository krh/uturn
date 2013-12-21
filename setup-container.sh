#!/bin/sh

# remove pam_loginuid line in /etc/pam.d/login 
# https://bugzilla.redhat.com/show_bug.cgi?id=966807
sed -i /loginuid/d /etc/pam.d/login

# delete root password
passwd -d root

# add build user and add to wheel group
user=krh
adduser $user
passwd -d $user
usermod -a -G wheel $user

# for 32 bit containers on 64 bit kernels, do ehco i386 >
# /etc/yum/vars/basearch and echo i686 > /etc/yum/vars/arch to make yum work.
#
# replace /usr/share/config.site with the uturn one that keys off of /sbin/init

systemctl enable uturn-builder.service
