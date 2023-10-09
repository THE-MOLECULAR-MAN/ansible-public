#!/bin/bash
# Tim H 2022

#./purge-ansible-osx.sh

# install it again
pip3 install   ansible

# pip3 install  ansible-core

# check versions:
ansible --version
ansible-galaxy --version
ansible-galaxy collection list

# only do this if I was running ansible on a LOT of assets:
#sudo launchctl limit maxfiles unlimited
