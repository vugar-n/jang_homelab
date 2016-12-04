#!/bin/sh
# add fail2ban rule for sshd 
echo -e "[sshd]\nenabled = true" >> /etc/fail2ban/jail.local

