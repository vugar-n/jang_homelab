#!/bin/sh

sshd_config=/etc/ssh/sshd_config

# added_sshd is the wishlist file containing sshd config options that you want to add or modify to sshd_config file
added_sshd=/root/firstboot/add_sshd-fb.txt

# word of caution: If there is duplicated keyword in either sshd_config file or wishlist file
# then this script won't work. Modification to the script would be needed to handle duplicates.
# This script skips the following keyword: HostKey

# check in sshd_config to see if the lines from the wishlist file is found there. 
# if yes, then modify those lines. Otherwise, append the wishlist lines that were not found in sshd_config
for line in $(grep -v -e "^#" -e "^$" $added_sshd | awk ' { print $1 } '  )
do
        newline="$(grep -m 1 "^$line" $sshd_config)"
        added_line="$(grep $line $added_sshd)"
        if [ "$line" = "$(echo $newline | awk ' { print $1 } ' )" ]
        then
                # HostKey keyword is ignored due to possible duplicate
                if [ ! "$line" = "HostKey" ]
                then
                        sed -i "s,^$newline.*$,$added_line,g" $sshd_config
                fi
        else
                echo $added_line >> $sshd_config
        fi
done

