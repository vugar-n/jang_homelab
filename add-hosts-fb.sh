#!/bin/sh

echo -e \
"172.16.1.50 hostname.domain.net hostname\n\
192.168.122.50 server1.example.com server1\n\
192.168.122.150 tester1.example.com tester1\n\
192.168.100.100 outsider1.example.org outsider1\n\
192.168.100.50 clone1.example.org clone1" >> /etc/hosts

