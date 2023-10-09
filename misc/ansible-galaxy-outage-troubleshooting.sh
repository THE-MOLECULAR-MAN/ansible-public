#!/bin/bash
# Tim H 2022
# check the site to see if there are errors
curl -v https://galaxy.ansible.com
dig galaxy.ansible.com

dig @1.1.1.1 galaxy.ansible.com
# clear local DNS cache on CentOS 7:
sudo /bin/systemctl restart dnsmasq.service
#ERROR! Error when finding available api versions from default (https://galaxy.ansible.com) (HTTP Code: 530, Message: )
#ERROR! Error when getting available collection versions for ansible.posix from default (https://galaxy.ansible.com/api/) (HTTP Code: 530, Message:  Code: Unknown)
# manual test with curl:
curl --resolve 'galaxy.ansible.com:443:172.67.68.251' https://galaxy.ansible.com
echo "104.26.1.234 galaxy.ansible.com" >> /etc/hosts

# it eventually fixed itself after like 20-30 minutes
