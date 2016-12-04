#!/bin/sh
echo "ALL:ALL" >> /etc/hosts.deny
echo "sshd:ALL" >> /etc/hosts.allow
echo "vsftpd:ALL" >> /etc/hosts.allow

