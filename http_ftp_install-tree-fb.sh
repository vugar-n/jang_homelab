#!/bin/sh

# set up HTTP and FTP install trees

mkdir -p /var/www/html/inst/ /var/ftp/pub/inst
wget -qO /root/CentOS-7-x86_64-DVD-1511.iso http://172.16.1.250/centos_image/CentOS-7-x86_64-DVD-1511.iso
modprobe loop
mount -r -o loop -t iso9660 /root/CentOS-7-x86_64-DVD-1511.iso /media
echo /var/www/html/inst /var/ftp/pub/inst | xargs -n 1 cp -a /media/.
semanage fcontext -a -t httpd_sys_content_t "/var/www/html(/.*)?"
semanage fcontext -a -t public_content_t "/var/ftp/pub(/.*)?"
restorecon -R /var/www/html
restorecon -R /var/ftp/pub
systemctl restart httpd.service && systemctl restart vsftpd.service

