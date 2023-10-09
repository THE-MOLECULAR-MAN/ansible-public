#!/bin/bash
# Tim H 2023
# basic test of trial code

# stop immediately if any errors occur
set -e

# brew reinstall ansible ansible-lint
# brew link --overwrite ansible

INVENTORY_FILE="inventories/ansible-hosts.homelab"

#echo "lint testing starting..."
#ansible-lint     playbooks/playbook-osx-brewtest.yml

# https://docs.brew.sh/Manpage
export HOMEBREW_NO_INSTALL_CLEANUP=TRUE 
export HOMEBREW_NO_ENV_HINTS=1 

echo "lint test finished. Starting playbook FAST..."
ansible-playbook playbooks/playbook-osx-brewtest.yml  --ask-become-pass -i "$INVENTORY_FILE"


echo "lint test finished. Starting playbook SLOW..."
ansible-playbook playbooks/playbook-osx-brew-old-slow.yml  --ask-become-pass -i "$INVENTORY_FILE"
