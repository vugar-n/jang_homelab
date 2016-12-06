RHCSA/RHCE Automated Homelab Configurator
=========================================

###PURPOSE:
This is a linux homelab configurator based on lab scenarios in seventh edition of Michael Jang's RHCSA/RHCE book. In this repository, all shell scripts are written in bash. With this configurator, you'd be able to build the entire lab from scratch directly on bare metal within a matter of two hours. While there are faster deployment solutions out there, this is intended to be used as a learning lab as one would be able to see how automation work in pieces using only bash and works with exercises in Jang's book for RHCSA/RHCE. No configuration management tool was used in this configurator.

###DISCLAIMER:
*This homelab configurator and/or this repository is not affiliated, endorsed, or sponsored by Michael Jang, Alessandro Orsaria, and McGraw-Hill Global Education Holdings, LLC, McGraw-Hill School Education Holdings, LLC, or one of their affiliated companies ("MHE" or "us" or "we").*

### **WARNING:** PLEASE READ BEFORE CONTINUING
**YOU MAY LOSE ALL YOUR DATA IF YOU ATTEMPT TO USE THIS CONFIGURATOR WITHOUT READING THE PREREQUISITES AND EXPECTATIONS BELOW.**


###PREREQUISITIES:
- CentOS 7.2 HTTP install tree (for physical machine) is located at the IP address:  `172.16.1.250/24`
- The private key (for private repository on Bitbucket.org) is located at `http://172.16.1.250/kickstart/hostname`
- The CentOS 7.2 ISO image is also located on the same server at `http://172.16.1.250/centos_image/CentOS-7-x86_64-DVD-1511.iso`
- All files in this repository are in a Bitbucket private repository
- Your public SSH key is added to [*custom_user.authorized_keys*](./custom_user.authorized_keys) file
- Primary hard drive is on `/dev/sda` with two pre-existing Windows partitions on `/dev/sda1` and `/dev/sda2` with at least 120 GB of remaining free space
- `/dev/sda` uses **MBR** partition table
- SSD is connected as third drive on `/dev/sdc` with a capicity of at least 100 GB. 
- `/dev/sdc` uses GUID partition table (**GPT**)
- You would need to supply your own /etc/ssmtp/ssmtp.conf file. You can follow the [Arch's wiki here](https://wiki.archlinux.org/index.php/SSMTP) for guidance. You only need to supply the configuration file to receive IP address change notification to your email as [*ssmtp-fb.sh*](./ssmtp-fb.sh) and [*check_ip.sh*](./check_ip.sh) scripts have done most of the heavy lifting for you. This can be completed later after the entire lab configuration is complete. Also, you'd need to update the email in [*check_ip.sh*](./check_ip.sh) script.



###WHAT TO EXPECT:
- This configurator will erase all of the partitions on `/dev/sdc` drive as well as all remaining partitions on `/dev/sda` that are not **NTFS** on either first or second primary partitions. `/dev/sdc` must use **GPT** and `/dev/sda` must use **MBR** for the erasure to be successful. If you have **NTFS** partition on `/dev/sda3` and beyond, you can also expect to lose data on those partitions as you won't be prompted with a warning. Backing up your data is strongly recommended, and you may proceed at your own risk without doing so. 
- The erasure occurs during the **%pre** script phase in Anaconda when using the [*hostname-ks.cfg*](./hostname-ks.cfg) kickstart file. This means before you can even see the installer UI, your data is probably already gone.
- The virtual machines do not use RAW image storage backend typically located in `/var/lib/libvirt/images` directory. They use **LVM** storage pool instead for performance reason. Each logical volume would be a hard disk drive inside the VM guests. It is ideal that you have good understanding of how **LVM** works.
- The VMs are fresh install using only **Server with GUI** package group. Nothing more or less. You can start lab exercises starting at Chapter 3 in Jang's book.
- In my environment, this configurator takes about 2 hours to complete. Your mileage may vary.

###SYSTEM CONFIGURATION:
**Operating system:** CentOS 7.2  
**Hostname:** hostname.domain.net  
**IP address:** 172.16.1.50/24 (static)  
**Gateway:** 172.16.1.1  
**Nameserver:** 172.16.1.1  
**Administrative user:** custom_user  
**/boot partition**: mount on `/dev/sda3` (size 768 MiB)  
**LVM use?:** Volume Group **mainVG** on `/dev/sda5` (use entire remaining disk space)  
**/home:** mount on `/dev/mainVG/home` (size 40 GiB)  
**/ (root):** mount on `/dev/mainVG/root` (all remaining space)  
**swap space:** mount on `/dev/mainVG/swap` (size 2 GiB)

###SECURITY CONCERN: 
The security implication of this homelab configurator is by no means very secured. If you are uncomfortable having your private key sitting on a local web server, then feel free make customization to the [*hostname-ks.cfg*](./hostname-ks.cfg) kickstart file in **%post** script section. Instead, you can actually have the entire install tree and private key on a USB. 


###FILES OVERVIEW: 
To understand how this configurator comes together in pieces, inspect each file in the following order:

*[hostname-ks.cfg](./hostname-ks.cfg)*
  > Kickstart file for physical machine to set up KVM hypervisor/libvirt to host VMs
  
*[main-script-fb.sh](./main-script-fb.sh)*
  > Main script executes each script below in sequential order
  
*[sysctl-fb.sh](./sysctl-fb.sh)*
  > Configure kernel runtime parameter
  
*[tcpwrapper-fb.sh](tcpwrapper-fb.sh)*
  > To allow or deny services from host
  
*[firewall-fb.sh](./firewall-fb.sh)*
  > Configure firewalld rules using firewall-cmd
  
*[sshd_config_modifier-fb.sh](./sshd_config_modifier-fb.sh)*
  > Modify the `/etc/ssh/sshd_config` file for SSH server
  
*[add_sshd-fb.txt](./add_sshd-fb.txt)*
  > Wishlist file for above script to add/modify sshd_config keywords
  
*[ssh-selinux-port-fb.sh](./ssh-selinux-port-fb.sh)*
  > Change the default **SELinux** port context for SSH port 
  
*[fail2ban-fb.sh](./fail2ban-fb.sh)*
  > Set up **fail2ban** for SSH
  
*[restart-firewall-sshd-fb.sh](./restart-firewall-sshd-fb.sh)*
  > Restart **SSH**, **firewalld**, and **fail2ban** services to put new changes in effect
  
*[lvm_cache_trim-fb.sh](./lvm_cache_trim-fb.sh)*
  > Set up **LVM** **cache** for root directory on HDD and enable **TRIM** for SSD optimization
  
*[rebuilt4next_reboot-fb.sh](./rebuilt4next_reboot-fb.sh)*
  > Rebuild the initial RAM disk to ensure system is bootable with TRIM and LVM cache enabled
  
*[ssmtp-fb.sh](./ssmtp-fb.sh)*
  > Set up **SSMTP** mail transfer agent (**MTA**) to receive email notification of public IP address change
  
*[check_ip.sh](./check_ip.sh)*
  > The above script depends on this script to check IP address change.
  
*[http_ftp_install-tree-fb.sh](./http_ftp_install-tree-fb.sh)*
  > Set up **HTTP** and **FTP** install trees on the physical server for VMs
  
*[add-hosts-fb.sh](./add-hosts-fb.sh)*
  > Resolve physical machine's and VMs' hostnames in `/etc/hosts`
  
*[libvirt-prep-fb.sh](./libvirt-prep-fb.sh)*
  > Prepare networks and storage pools for VMs
  
*[kscreator-fb.sh](./kscreator-fb.sh)*
  > Create kickstart file uniquely for each VM
  
*[kstemplate-fb.cfg](./kstemplate-fb.cfg)*
  > Kickstart template files for above script
  
*[build-vms-fb.sh](./build-vms-fb.sh)*
  > Set up VMs and install guest OSes
  
The security configurations in the following scripts and configuration files are by no means exhaustive and is not recommended for use outside of personal homelab:

- *[sysctl-fb.sh](./sysctl-fb.sh)* 
- *[tcpwrapper-fb.sh](tcpwrapper-fb.sh)* 
- *[add_sshd-fb.txt](./add_sshd-fb.txt)*
- *[fail2ban-fb.sh](./fail2ban-fb.sh)*
