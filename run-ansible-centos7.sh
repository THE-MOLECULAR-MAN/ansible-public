#!/bin/bash
# Tim H 2021
# NOT_FOR_PUBLIC_RELEASE

# Ansible scripts for CentOS 7
# This script is to be run from OS X or your Linux laptop
# https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html

clear 


# bail immediately on any errors
set -e

##############################################################################
#   MAIN
##############################################################################
./test-playbook.sh playbooks/playbook-centos7-authtest.yml
./test-playbook.sh playbooks/playbook-centos7-basic.yml
./test-playbook.sh playbooks/playbook-centos7-domained.yml
./test-playbook.sh playbooks/playbook-linux-virtual-machines.yml
./test-playbook.sh playbooks/playbook-centos7-free-up-space.yml
#./test-playbook.sh playbooks/playbook-centos7-update-kernel-reboot.yml


#    14  sudo yum groupinstall -y 'Development Tools'

#      197  yum remove subscription-manager - check ramifications on Kubernetes first
#   no can do on docker hosts
# subscription manager is disabled or uninstalled
# 	can't be if Docker is installed

#   229  yum -qy install @development-tools

# yum autoremove
#   137  yum autoclean
#   138  yum clean all


# - name: Clean unwanted olderstuff
#             apt:
#                     autoremove: yes
#                     purge: yes

# Warn if Java installed
#   264  yum remove java-11-openjdk
# make sure smtp is not installed
