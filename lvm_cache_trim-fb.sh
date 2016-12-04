#!/bin/sh

# This script configures LVM cache and TRIM

# configure /dev/sdc (solid state drive) for LVM cache
sgdisk -Z /dev/sdc
sgdisk -n 1:0:+20G -t 1:8e00 -c 1:"host LVM cache" /dev/sdc
partprobe /dev/sdc

# set up LVM
pvcreate /dev/sdc1
vgextend mainVG /dev/sdc1
lvcreate -n mainVGcache -L19.9G mainVG /dev/sdc1
lvcreate -n mainVGcacheMeta -L20M mainVG /dev/sdc1
lvconvert -y --type cache-pool --poolmetadata mainVG/mainLVcacheMeta mainVG/mainVGcache
lvconvert -y --type cache --cachepool mainVG/mainVGcache mainVG/root

# set up TRIM for LVM
sed -i 's/issue_discards = 0/issue_discards = 1/g' /etc/lvm/lvm.conf

# enable TRIM at boot
systemctl enable fstrim.timer

