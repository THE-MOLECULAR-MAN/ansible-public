#!/bin/bash
# Tim H 2021
#
# Test Ansible YML files

# bail immediately on any failures
set -e

# pip3 install "ansible-lint"

# check static config file first, don't want to run it as playbook
yamllint requirements.yml

# Read the array values with space
for ITER_PLAYBOOK_FILENAME in playbook-*.yml; do
    yamllint --no-warnings "$ITER_PLAYBOOK_FILENAME"
    # ansible-lint "$ITER_PLAYBOOK_FILENAME"    # broken for now
    #set -e
    ansible-lint "$ITER_PLAYBOOK_FILENAME"
    ansible-playbook --syntax-check "$ITER_PLAYBOOK_FILENAME" -i ansible-hosts.homelab
    #set +e
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ finished $ITER_PLAYBOOK_FILENAME"
done
