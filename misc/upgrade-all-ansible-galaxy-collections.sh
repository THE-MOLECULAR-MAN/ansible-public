#!/bin/bash
# Tim H 2021

set -e

# manual test:
# ansible-galaxy collection install ansible.utils --upgrade

# get a list of the collections that are installed
ansible-galaxy collection list | cut -d ' ' -f1 | grep "\." | grep "^[^#;]" | sort --unique | while read -r ITER_COLLECTION_NAME ; do
    echo "$ITER_COLLECTION_NAME"
    ansible-galaxy collection install "$ITER_COLLECTION_NAME"
done

