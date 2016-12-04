#!/bin/sh

# abort script if it has been executed already
if [ -f /root/firstboot/.ranonce ]
then
	echo "Exiting main-script-fb.sh.... This script has ran once already. [ $(date) ]"
	logger "Exiting main-script-fb.sh.... This script has ran once already. [ $(date) ]"
	chmod -x /root/firstboot/main-script-fb.sh
	chmod -x /etc/rc.d/rc.local
	exit 66
fi

touch /root/firstboot/.ranonce

scriptfiles="
sysctl-fb.sh
tcpwrapper-fb.sh
firewall-fb.sh
sshd_config_modifier-fb.sh
ssh-selinux-port-fb.sh
fail2ban-fb.sh
restart-firewall-sshd-fb.sh
lvm_cache_trim-fb.sh
rebuilt4next_reboot-fb.sh
ssmtp-fb.sh
http_ftp_install-tree-fb.sh
add-hosts-fb.sh
libvirt-prep-fb.sh
kscreator-fb.sh
build-vms-fb.sh
"

# execute each script at a time

for script in $scriptfiles
do
	echo "--- [ $(date) ] ---" >> /root/firstboot/$script.output
	/bin/bash -x /root/firstboot/$script >>/root/firstboot/$script.output 2>&1

	# abort the main script in case of error
	if [ $? -ne 0 ]
	then
		echo  "ERROR: $script in main-script has failed at $(date)"
		logger -i "ERROR: $script in main-script has failed at $(date)"
		exit 99
	fi
done

echo "+++++++++++ THIS SCRIPT HAS COMPLETED SUCCESSFULLY AT $(date) ++++++++++"
chmod -x /root/firstboot/main-script-fb.sh
chmod -x /etc/rc.d/rc.local

reboot