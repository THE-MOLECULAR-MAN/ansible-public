#!/bin/bash
# Tim H 2022

# https://access.redhat.com/downloads/content/480/ver=2.2/rhel---9/2.2/x86_64/product-software
# https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform
# https://docs.ansible.com/ansible-tower/latest/html/quickinstall/prepare.html#prerequisites-and-requirements

# Ansible Automation Platform (formerly Tower) install guide

#wget "https://access.cdn.redhat.com/content/origin/files/sha256/83/835161225aec0bc18421978985870a7d3a0d54667dc659b68a358ba32256a8fb/ansible-automation-platform-setup-2.2.0-6.tar.gz?user=92f7b2fe762468ad0a4c14d80999062f&_auth_=1653591401_850d75a13c0bc63d38261de89878327f"
#mv ansible-automation-platform-setup-2.2.0-6.tar.gz*            ansible-automation-platform-setup-2.2.0-6.tar.gz
# 835161225aec0bc18421978985870a7d3a0d54667dc659b68a358ba32256a8fb

#wget "https://access.cdn.redhat.com/content/origin/files/sha256/a9/a9895d2a4c190b02fbfb341fa129c9682542e34bb5f482c963127329a3c43f42/ansible-automation-platform-setup-bundle-2.2.0-6.tar.gz?user=92f7b2fe762468ad0a4c14d80999062f&_auth_=1653591401_abe7b2e835e3fb9dcf4e3b704b8f09f8"
#mv ansible-automation-platform-setup-bundle-2.2.0-6.tar.gz*     ansible-automation-platform-setup-bundle-2.2.0-6.tar.gz
# a9895d2a4c190b02fbfb341fa129c9682542e34bb5f482c963127329a3c43f42

#wget "http://installers.int.butters.me:8081/ansible-automation-platform-setup-2.2.0-6.tar.gz"
#wget "http://installers.int.butters.me:8081/ansible-automation-platform-setup-bundle-2.2.0-6.tar.gz"

#sha256sum ansible-*.tar.gz

yum install -y subscription-manager

echo "[main]
enabled=1" | sudo tee /etc/yum/pluginconf.d/subscription-manager.conf
yum makecache

# create a RedHat account and make sure that you click the activation link in the email
subscription-manager --insecure register --username=butters.homelab

# Go here and assign the Ansible Automation Platform trial license to this system 
# https://access.redhat.com/management/systems

subscription-manager list --available --all | grep "Ansible Automation Platform" -B 3 -A 6
#subscription-manager list --consumed

# install pre-reqs, must use pip for ansible-core, not yum for ansible
# have to upgrade pip first, default version with CentOS will not work
# the default URL won't work either since CentOS has Python 3.6, not 3.7 or later
# also, the --upgrade method doesn't work either.
# wget https://bootstrap.pypa.io/pip/3.6/get-pip.py
# python3 get-pip.py

# do NOT run this as root or with sudo
# pip3 install ansible-core

# https://docs.ansible.com/ansible-tower/latest/html/quickinstall/prepare.html#notes-for-rhel-and-centos-setups
# the online guide
# https://computingforgeeks.com/install-and-configure-ansible-tower-on-centos-rhel/
sudo yum -y install epel-release
sudo yum -y install ansible vim curl
mkdir /tmp/tower
cd  /tmp/tower || exit 1
curl -k -O https://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-latest.tar.gz
tar xvf ansible-tower-setup-latest.tar.gz
cd ansible-tower-setup*/ || exit 2
vim inventory
sudo ./setup.sh


# https://ansible-automation-platform.int.butters.me
# initial login username: admin
# password is admin_password from the inventory file
# MUST USE CHROME, doesn't work with firefox
# 

# install some more dependencies
# seeing errors, it's probably cloudflare outage
ansible-galaxy -vvvv collection install ansible.posix
ansible-galaxy -vvvv collection install geerlingguy.php_roles
ansible-galaxy -vvvv collection install ansible.posix.selinux

# gotta do this before creating a project
sudo mkdir -p /var/lib/awx/projects/homelab1
sudo chown awx /var/lib/awx/projects/homelab1
sudo chown -R awx /var/lib/awx  # this is important
# must be recursive, let myself SCP files into some subdirectories
sudo chgrp -R "domain users@int.butters.me" /var/lib/awx
sudo chmod 770 /var/lib/awx/projects/homelab1
# restart the service so that errors won't happen
ansible-tower-service restart
# show perms
ls -lah /var/lib/awx/projects/homelab1

# copy the files over from laptop for testing
cd "$HOME/source_code/honker-private-personal/ansible/" || exit 4
scp playbook-*.yml  ansible-automation-platform.int.butters.me:/var/lib/awx/projects/homelab1/

ansible-tower-service status

zgrep -i "error" /var/log/tower/*
tail -n0 -f /var/log/tower/* | grep -i "error" 

# /var/lib/awx/

# paths for galaxy modules:
# /usr/lib/python2.7/site-packages/ansible
# /root/.ansible/collections/ansible_collections/ansible/posix
# /home/thonker.adm@int.butters.me/.ansible/collections/ansible_collections
# env: /var/lib/awx/venv/ansible

cd /var/lib/awx/venv/ansible || exit 5
find . -type d -iname '*collection*'
