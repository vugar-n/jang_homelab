#!/bin/sh

# Prepare libvirt for new VMs

# Clone the "default" network and rename to "outsider"
cp /etc/libvirt/qemu/networks/default.xml /etc/libvirt/qemu/networks/outsider.xml


# Modify the outsider.xml file 
sed -i '/<host/d' /etc/libvirt/qemu/networks/outsider.xml
sed -i 's/<name>.*</<name>outsider</g' /etc/libvirt/qemu/networks/outsider.xml
sed -i '/<uuid>.*<\/uuid>/d' /etc/libvirt/qemu/networks/outsider.xml
sed -i "s/<bridge name='[^']*'/<bridge name='virbr1'/g" /etc/libvirt/qemu/networks/outsider.xml
sed -i '/<mac.*\/>/d' /etc/libvirt/qemu/networks/outsider.xml
sed -i "s/<ip address='[^']*' netmask='[^']*'>/<ip address='192.168.100.1' netmask='255.255.255.0'>/g" /etc/libvirt/qemu/networks/outsider.xml
sed -i "s/<range start='[^']*' end='[^']*'/<range start='192.168.100.128' end='192.168.100.254'/g" /etc/libvirt/qemu/networks/outsider.xml


# Persistently add Outsider network to libvirt
virsh net-define /etc/libvirt/qemu/networks/outsider.xml

# Start and automatically boot up Outsider network
virsh net-autostart outsider
virsh net-start outsider

# Add DHCP clients for Default network:
virsh net-update default add ip-dhcp-host "<host mac='00:11:22:33:44:01' name='server1' ip='192.168.122.50' />" --config --live
virsh net-update default add ip-dhcp-host "<host mac='00:11:22:33:44:11' name='tester1' ip='192.168.122.150' />" --config --live

# Add the DHCP clients for Outsider network:
virsh net-update outsider add ip-dhcp-host "<host mac='00:11:22:33:44:21' name='outsider1' ip='192.168.100.100' />" --config --live
virsh net-update outsider add ip-dhcp-host "<host mac='00:11:22:33:44:31' name='clone1' ip='192.168.100.50' />" --config --live


# Format 4 more partitions on /dev/sdc drive:
sgdisk -n 2:0:+18G -t 2:8e00 -c 2:"server1 LVM" /dev/sdc
sgdisk -n 3:0:+18G -t 3:8e00 -c 3:"tester1 LVM" /dev/sdc
sgdisk -n 4:0:+18G -t 4:8e00 -c 4:"outsider1 LVM" /dev/sdc
sgdisk -n 5:0:+18G -t 5:8e00 -c 5:"clone1 LVM" /dev/sdc
partprobe /dev/sdc

# Set up physical volumes on all partitions:
pvcreate /dev/sdc2
pvcreate /dev/sdc3
pvcreate /dev/sdc4
pvcreate /dev/sdc5


# Define libvirt storage pool:
virsh pool-define-as server1 logical - - /dev/sdc2 server1
virsh pool-define-as tester1 logical - - /dev/sdc3 tester1
virsh pool-define-as outsider1 logical - - /dev/sdc4 outsider1
virsh pool-define-as clone1 logical - - /dev/sdc5 clone1


# Build the defined storage pool:
virsh pool-build server1
virsh pool-build tester1
virsh pool-build outsider1
virsh pool-build clone1


# Autostart the storage pool:
virsh pool-autostart server1
virsh pool-autostart tester1
virsh pool-autostart outsider1
virsh pool-autostart clone1

# Start the storage pool:
virsh pool-start server1
virsh pool-start tester1
virsh pool-start outsider1
virsh pool-start clone1

# Create logical volumes for each pool:
virsh vol-create-as server1 hdd1 16G
virsh vol-create-as server1 hdd2 1G
virsh vol-create-as server1 hdd3 1020M
virsh vol-create-as tester1 hdd1 16G
virsh vol-create-as tester1 hdd2 1G
virsh vol-create-as tester1 hdd3 1020M
virsh vol-create-as outsider1 hdd1 16G
virsh vol-create-as outsider1 hdd2 1G
virsh vol-create-as outsider1 hdd3 1020M
virsh vol-create-as clone1 hdd1 16G
virsh vol-create-as clone1 hdd2 1G
virsh vol-create-as clone1 hdd3 1020M

