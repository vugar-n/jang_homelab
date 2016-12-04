#!/bin/sh
systemctl restart fail2ban.service
systemctl restart firewalld.service
systemctl restart sshd.service

