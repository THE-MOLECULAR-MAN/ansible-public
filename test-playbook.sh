#!/bin/bash
# Tim H 2021,2022

# Validate the syntax and then run a single Ansible playbook

set -e

PLAYBOOK_PATH="$1"

if [ -f "$PLAYBOOK_PATH" ]; then
    # cd "$HOME/source_code/ansible/"
    #yamllint --no-warnings          "$PLAYBOOK_PATH"
    #ansible-playbook --syntax-check "$PLAYBOOK_PATH" -i inventories/ansible-hosts.homelab
    ansible-lint  "$PLAYBOOK_PATH"
    ansible-playbook             "$PLAYBOOK_PATH" -i inventories/ansible-hosts.homelab
else 
    echo "$PLAYBOOK_PATH does not exist."
    exit 1
fi

# echo "script finished successfully."
