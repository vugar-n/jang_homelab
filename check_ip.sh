#!/bin/sh
# This script updates the file if the public IP address has changed

ipaddr=""


if [[ $(cat ~/current_public_ip.txt) = $(curl -4s http://www.icanhazip.com) ]]
then
        logger -p local0.info "No change to public IP address"
else
        ipaddr=$(curl -4s http://www.icanhazip.com)
        echo "IP address has changed to $ipaddr" | mail -s "IP change" sendit2me@myemail.com
        echo $ipaddr > ~/current_public_ip.txt
        logger -p local0.notice "IP address has changed to $ipaddr"
fi

