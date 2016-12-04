#!/bin/sh

# list of hosts
host="server1 tester1 outsider1 clone1"

# kickstart template file
kickstarter=/root/firstboot/kstemplate-fb.cfg

# location for new ks files
folder=/root/firstboot

# inject the public key created in post-install script
sed -i "s,SSHKEY,$(cat /root/.ssh/id_rsa.pub),g" $kickstarter

# create kickstart file for each host with correct information and set 600 permission on file
for server in $host
do
	if [ $server = "outsider1" ] || [ $server = "clone1" ]
	then
		sed "s/SERVERHOST/$server/g" \
		$kickstarter | 
		sed "s/--hostname=$server.example.com/--hostname=$server.example.org/g" > \
$folder/"$server"-ks.cfg
	else
		sed "s/SERVERHOST/$server/g" $kickstarter > $folder/"$server"-ks.cfg
	fi
	chmod 600 $folder/"$server"-ks.cfg
done

