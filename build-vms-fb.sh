#!/bin/sh

# This script creates 4 VMs
# first three are created frmo scratch
# last one is cloned from the first VM.

# list of hosts
host="server1 tester1 outsider1"

# server1.example.com
# 00:11:22:33:44:01

# tester1.example.com
# 00:11:22:33:44:11

# outsider1.example.org
# 00:11:22:33:44:21

# clone1.example.org
# 00:11:22:33:44:31

# create the first 3 VMs
for server in $host
do
	domain=""
	mac=""
	network=""

	case $server in
		"server1")
			domain="example.com"
			mac="00:11:22:33:44:01"
			network="default"
			;;
			
		"tester1")
			domain="example.com"
			mac="00:11:22:33:44:11"
			network="default"
			;;
			
		"outsider1")
			domain="example.org"
			mac="00:11:22:33:44:21"
			network="outsider"
			;;
			
		*)
			echo "ERROR WITH CASE IN VIRT-INSTALL SCRIPT"
			exit 64
	esac

	virt-install \
	--name $server.$domain \
	--location ftp://172.16.1.50/pub/inst \
	--os-type=linux \
	--os-variant centos7.0 \
	--memory 1024 \
	--graphics none \
	--network network=$network,model=virtio,mac=$mac \
	--disk device=disk,path=/dev/$server/hdd1,bus=scsi,cache=none,discard=unmap,format=raw \
	--disk device=disk,path=/dev/$server/hdd2,bus=scsi,cache=none,discard=unmap,format=raw \
	--disk device=disk,path=/dev/$server/hdd3,bus=scsi,cache=none,discard=unmap,format=raw \
	--serial pty,name=serial0 \
	--console pty,target_type=serial,name=serial0 \
	--serial pty,name=console1 \
	--console pty,target_type=virtio,name=console1 \
	--controller scsi,model=virtio-scsi \
	--initrd-inject "/root/firstboot/$server-ks.cfg" \
	--extra-args "inst.ks=file:/$server-ks.cfg" \
	--noautoconsole \
	--noreboot
	
	# wait for domain to complete install and shutdown before next domain install
	# this is required for virt-clone to work successfully later
	sleep 1
	while [ $(virsh domstate $server.$domain) == "running" ]
	do
		sleep 1
	done
	
done

# clone the fourth VM from the first VM

# copy the server1 XML config file
virsh dumpxml server1.example.com > /tmp/original.xml

# delete the channel tags in copied file
sed -i '/<channel/,/<\/channel>$/d' /tmp/original.xml

# build VM using copied file
virt-clone \
--original-xml /tmp/original.xml \
--name clone1.example.org \
--check path_exists=off \
--file /dev/clone1/hdd1 \
--file /dev/clone1/hdd2 \
--file /dev/clone1/hdd3 \
--mac 00:11:22:33:44:31 

# delete original file
rm -f /tmp/original.xml

# remove interface to avoid duplicate
virsh dumpxml clone1.example.org | grep -A4 -B1 -m1 00:11:22:33:44:31 > /tmp/bad-interface.xml
virsh detach-device clone1.example.org /tmp/bad-interface.xml --persistent
rm -f /tmp/bad-interface.xml

# replace new interface
virsh attach-interface clone1.example.org \
--type network \
--source outsider \
--mac 00:11:22:33:44:31 \
--model 'virtio' \
--persistent


# gut out the old configs from cloned system
virt-sysprep \
--operations defaults,-ssh-userdir \
--firstboot-command 'vgrename server1VG1 clone1VG1' \
--firstboot-command "sed -i.backup 's/server1VG1/clone1VG1/g' /etc/fstab" \
--firstboot-command "sed -i.backup 's/server1VG1/clone1VG1/g' /boot/grub2/grub.cfg" \
--hostname clone1.example.org \
--domain clone1.example.org
