#!/bin/sh

# change SSH port and allow HTTP and FTP traffic internally for libvirt VMs
firewall-cmd --permanent --add-port=2222/tcp
firewall-cmd --permanent --remove-service=ssh
firewall-cmd --permanent --add-service=ftp --zone=internal 
firewall-cmd --permanent --add-service=http --zone=internal 
firewall-cmd --permanent --add-interface=virbr0 --zone=internal
firewall-cmd --permanent --add-interface=virbr1 --zone=internal

