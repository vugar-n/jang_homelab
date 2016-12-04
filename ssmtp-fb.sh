#!/bin/sh

# set up ssmtp for public IP address change alert

alternatives --set mta /usr/sbin/sendmail.ssmtp
useradd -c "Mail Sender" -m -r -s /sbin/nologin mailsender
passwd -l mailsender
echo -e "# Check the public IP every hour to see if it has changed\n0 */1 * * * ~/check_ip.sh" > /home/mailsender/cronjob.txt
crontab -u mailsender /home/mailsender/cronjob.txt
curl -4s http://www.icanhazip.com > /home/mailsender/current_public_ip.txt
cd /home/mailsender/
eval "$(/usr/bin/ssh-agent)"
ssh-add /root/.ssh/id_rsa_bitbucket
if [ ! "$(grep ^bitbucket.org ~/.ssh/known_hosts)" ]
then
        ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts
fi
git init
git fetch private_repo:myaccount/myrepo.git
git checkout FETCH_HEAD 'check_ip.sh'
chown mailsender:mailsender /home/mailsender/*
chmod +x /home/mailsender/check_ip.sh
rm -rf .git
ssh-agent -k
cd /root/firstboot

