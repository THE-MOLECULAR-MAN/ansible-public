#!/bin/bash
# Tim H 2021
# NEEDS_TO_BE_SANTIZIED_BEFORE_PUBLIC_RELEASE
# NOT_FOR_PUBLIC_RELEASE

# One time setup for Ansible on OS X
# Designed to run from an OS X command line and connect out to other systems

# https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#control-node-requirements

##############################################################################
#   ONE TIME SETUP
##############################################################################

# bail immediately if anything fails
set -e

# have to install pip also, not just brew
# brew install pipx

# run these commands on OS X, be super quiet
pip3 install -qq ansible


# newer
alias python='/usr/bin/python3'

#sudo /bin/ln -s /usr/bin/python3 /usr/bin/python
#sudo /usr/bin/python3 get-pip.py

#/Library/Developer/CommandLineTools/usr/bin/python3     --> 3.8.9
# /usr/bin/python3                                       --> 3.8.9

# okay, there are multiple versions of Python installed on my system that are competing
/Library/Developer/CommandLineTools/usr/bin/python3 -m pip install --upgrade pip
/usr/bin/python3 -m pip install ansible

echo "Creating directories and changing permissions, might ask for sudo password."

# the -p is required to avoid errors with set -e
sudo mkdir -p /etc/ansible

#cp ansible-hosts /etc/ansible/hosts
#sudo chown -R "$(whoami)" /etc/ansible
#sudo chmod +r /etc/ansible/hosts

# verify the file exists, and has proper permissions
# ls -lah /etc/ansible

# install dependencies for lint checking
brew install --quiet yamllint

# ansible-lint # package is broken

python3 --version

# https://stackoverflow.com/questions/40684543/how-to-make-python-use-ca-certificates-from-mac-os-truststore
# http://www.cdotson.com/2017/01/sslerror-with-python-3-6-x-on-macos-sierra/

chown -R "$(whoami):staff" /Users/tim/Library/Caches
chmod -R u+w  /Users/tim/Library/Caches/pip

# update PIP before using it, do NOT use sudo here:
/Library/Frameworks/Python.framework/Versions/Current/bin/python3 -m pip install --upgrade pip

# gotta install Python's root CAs b/c recent versions don't use the OSX root CA library
pip install certifi
python3 -m certifi

# temporarily add these variables so Python (which ansible is built on) will use the correct CA store
CERT_PATH=$(python3 -m certifi)
export SSL_CERT_FILE=${CERT_PATH}
export REQUESTS_CA_BUNDLE=${CERT_PATH}

# make that change
echo "
# added manually so Ansible/Python will work with SSL:
CERT_PATH=$(python3 -m certifi)
export SSL_CERT_FILE=${CERT_PATH}
export REQUESTS_CA_BUNDLE=${CERT_PATH}
" | tee "$HOME/.bash_profile" "$HOME/.zshrc"

# install a dependency
ansible-galaxy collection install community.general

ansible-galaxy collection list

# install dependency for modifying sudoers; not used by these scripts/playbooks anymore
# https://github.com/ahuffman/ansible-sudoers#rhel76-default-sudoers-configuration
# ansible-galaxy install ahuffman.scan_sudoers  || echo "already installed scan_sudoers"

# this is broken
# pip3 install ansible-lint

# change the first line of /usr/local/bin/ansible-lint to match the first line of /usr/local/bin/ansible
# !/usr/local/opt/python@3.8/bin/python3.8
# only do this once and only once
# TODO: add check if backup file exists, if it does, skip this step
# cp /usr/local/bin/ansible-lint /usr/local/bin/.ansible-lint.backup
# head -n 1 /usr/local/bin/ansible
