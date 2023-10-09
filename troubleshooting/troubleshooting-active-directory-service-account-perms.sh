#!/bin/bash
# Tim H 2022
tail -n5 /etc/sudoers && cat /etc/sudoers.d/*

id svc-ansible@INT.BUTTERS.ME

ls -lah /home/svc-ansible@int.butters.me/.ssh/authorized_keys

cat /home/svc-ansible@int.butters.me/.ssh/authorized_keys
# double check the case on the domain name, directories are lower case

find /home/svc-ansible\@int.butters.me/ -ls

#fatal: [cron-runner.int.butters.me]: FAILED! => {"msg": "Failed to set permissions on the temporary files Ansible needs to create when becoming an unprivileged user (rc: 1, err: chmod: invalid mode: ‘A+user:svc-ansible@INT.BUTTERS.ME:rx:allow’\nTry 'chmod --help' for more information.\n}). For information on working around this, see https://docs.ansible.com/ansible-core/2.13/user_guide/become.html#risks-of-becoming-an-unprivileged-user"}

# seems like it is not recognizing the service account as having sudo powers
# 1) triple check to make sure system is joined to domain
# 2) look at other ways to verify it is joined to domain other than "id"
# 3) 

# https://yallalabs.com/linux/how-to-join-centos-7-rhel-7-servers-to-active-directory-domain-using-ansible/

vim /etc/krb5.conf

tail -n0 -f /var/log/k*.log
cat /etc/sssd/sssd.conf
grep "use_fully_qualified_names" /etc/sssd/sssd.conf
#     use_fully_qualified_names = False
#      systemctl restart sssd

sudo systemctl restart sssd.service
sudo systemctl restart  realmd.service

yum install samba-winbind glibc-common samba4 samba4-common samba4-client samba4-winbind samba4-winbind-clients nscd

winbindd -d 100
# getent group adm-host_administrators

id svc-ansible@INT.BUTTERS.ME
sudo su - svc-ansible@INT.BUTTERS.ME

# found it:
# winbind service must not be installed!

service winbind status

yum list installed  | cut -d ' ' -f1 | cut -d '.' -f1 | sort --unique > "yum_$HOSTNAME.txt"

scp ivm-scanner01.int.butters.me:./yum* .
scp cron-runner.int.butters.me:/home/thonker.adm@int.butters.me/yum_cron-runner.int.butters.me.txt .
scp ivm-scanner01.int.butters.me:/home/thonker.adm@int.butters.me/yum_ivm-scanner01.int.butters.me.txt .
scp ups-local01.int.butters.me:/home/thonker.adm@int.butters.me/yum_ups-local01.int.butters.me.txt .

diff --unchanged-line-format= --old-line-format= --new-line-format='%L' yum_ups-local01.int.butters.me.txt yum_cron-runner.int.butters.me.txt
diff --unchanged-line-format= --old-line-format= --new-line-format='%L' yum_ivm-scanner01.int.butters.me.txt yum_cron-runner.int.butters.me.txt

# remove all AD/Kerb related packages, get ready to re-join this device to the domain
realm leave INT.BUTTERS.ME
realm list
yum remove NetworkManager nscd samba samba-client samba-winbind samba-winbind-clients samba-client-libs samba-common samba-common-libs samba-common-tools samba-libs samba-winbind-modules adcli sssd-common sssd-krb5 sssd-krb5-common sssd-ldap sssd-proxy realmd krb5-devel krb5-workstation sssd-client
    
# rejoin
yum install -y realmd krb5-workstation oddjob oddjob-mkhomedir sssd samba-common-tools pam_krb5
DOMAIN_TO_JOIN="INT.BUTTERS.ME"                            # INT.CONTOSO.COM must be in ALL CAPS
DOMAIN_ADMIN_USERNAME="thonker.adm"                        # jdoe.adm, script will later prompt twice for this DA's password
realm discover "$DOMAIN_TO_JOIN"                        # check to see if the domain is visible
kinit -V "$DOMAIN_ADMIN_USERNAME"@"$DOMAIN_TO_JOIN"        # cache creds, verbose output
# Enter the password ONCE and then let it ride, it'll take care of it; no need to enter it again
realm join --verbose "$DOMAIN_TO_JOIN" -U "$DOMAIN_ADMIN_USERNAME@$DOMAIN_TO_JOIN"    # join it
realm list                                                # verify join was successful

id svc-ansible@INT.BUTTERS.ME

#### final list of packages
# Safe:
# samba-client-libs.x86_64                                      4.10.16-18.el7_9                                             @updates                                               
# samba-common.noarch                                           4.10.16-18.el7_9                                             @updates                                               
# samba-common-libs.x86_64                                      4.10.16-18.el7_9                                             @updates                                               
# samba-common-tools.x86_64                                     4.10.16-18.el7_9                                             @updates                                               
# samba-libs.x86_64                 
# kexec-tools.x86_64                                            2.0.15-51.el7_9.3                                            @updates                                               
# krb5-libs.x86_64                                              1.15.1-51.el7_9                                              @updates                                               
# krb5-workstation.x86_64                                       

# testing removing packages on working server before deploying everywhere
yum remove krb5-libs authconfig samba-common openldap-devel pam-devel
