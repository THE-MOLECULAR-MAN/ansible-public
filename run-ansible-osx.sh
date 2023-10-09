#!/bin/bash
# Tim H 2021,2023
#
# Ansible script for OS X
# This script is to be run from OS X laptop

# pre-req
# brew install ansible ansible-lint yamllint
# ansible-galaxy collection install community.general geerlingguy.mac
# mkdir -p ~/.config/yamllint
# echo "" > ~/.config/yamllint/config

# stop immediately if any errors occur
set -e

INVENTORY_FILE="inventories/ansible-hosts.homelab"

fix_python_permissions() {
     chown -R "$(whoami)" /usr/local/lib/python*
}

clean_python_cache() {
     echo "Deleting old Python cache. sudo is required."
     set +e
     # add the ~/Library/Python instead of just ~/
     # saves about 18 seconds - reduced from 22 seconds to 2 seconds
     sudo find /opt/homebrew/lib/ "$HOME/Library/Python" -path '*__pycache__*' -type f \
          -name '*.pyc' -delete 2>/dev/null
     
     #sudo find /usr/local/lib/python3.11/site-packages/__pycache__/ -type f -delete

     # really nuke stuff:
     # sudo find / -type f -path '*__pycache__*' -iname '*.pyc' -delete
     # sudo find /usr/local/bin/__pycache__ /usr/local/Caskroom /usr/local/lib/python* -type f -path '*__pycache__*'   -iname '*.pyc' -delete
     set -e
     
     echo "Finished deleting old Python cache."
}

upgrade_all_galaxy_collections() {
     # Tested on Macbook Air 2020
     # took 31 seconds to run when 219 ansible galaxy collections were installed
     # this method was 3.4 times faster than iterative loop
     # and no upgrades were needed

     COLLECTIONS_FILE="current_collections.yml"

     rm -f "$COLLECTIONS_FILE" current_collections.txt
    
     ansible-galaxy collection list --format json | jq '.[] | keys | .[]' --raw-output > current_collections.txt
     echo "---
collections:
" > "$COLLECTIONS_FILE"

     awk '{print "   - name: " $0}' current_collections.txt >> "$COLLECTIONS_FILE"
     echo "" >> "$COLLECTIONS_FILE"

     # yamllint "$COLLECTIONS_FILE"

     ansible-galaxy collection install --upgrade -r "$COLLECTIONS_FILE"

}

# make sure directory exists first
echo "Changing directories..."
cd "$HOME/source_code/ansible" || exit 3

# clear old cache since it can occasionally cause problems
echo "Deleting old Ansible cache..."
rm -Rf /Users/thonker/.cache/ansible-compat

# clearing Python cache, since this has caused a problem ONCE.
clean_python_cache

brew cleanup

# burp seems to cause issues sometimes and this fixes it
# yup, don't comment this out, it keeps happening and crashing my 
# ansible playbook later this seems to need to be high up in the script 
# to avoid issues.
brew reinstall --cask --quiet burp-suite

# force upgrade of ansible related packages to avoid warnings/errors later
echo "PIP: Upgrading Pip, Ansible, and Docker for each version of Python..."
# maybe avoid using sudo pip to avoid permissions issues?
# consider using sudo's -H flag instead?
# sudo python3    -m pip install -qqq --upgrade pip ansible-lint ansible docker-py
# sudo python3.10 -m pip install -qqq --upgrade pip ansible-lint ansible docker-py
# sudo was required b/c of some permissions
sudo python3    -m pip install -qqq --upgrade pip ansible-lint ansible
sudo python3.10 -m pip install -qqq --upgrade pip ansible-lint ansible docker-py


echo "PIP: Upgrading Ansible Lint..."
pip install -qqq --upgrade ansible-lint

# need this if ansible is upgraded, otherwise the script will stop here.
# might need to make this || on the brew upgrade
echo "BREW: Upgrading Ansible Lint and Ansible..."
brew upgrade --quiet ansible-lint ansible || brew link --overwrite ansible

# install ansible galaxy collection dependencies if not already installed
echo "ANSIBLE-GALAXY: installing pre-reqs..."
# ansible-galaxy install -r requirements.yml
# much faster way to upgrade all packages:
ansible-galaxy collection install --upgrade -r requirements.yml

# ansible-galaxy collection install ansible.netcommon ansible.posix \
#      ansible.utils ansible.windows community.general community.crypto \
#      community.dns community.docker community.network community.vmware \
#      community.windows geerlingguy.mac sensu.sensu_go \
#      --upgrade

# ansible-galaxy collection install git+https://github.com/geerlingguy/ansible-collection-mac
# ansible-galaxy collection install community.general:6.3.0

# upgrade all installed ansible galaxy collections
# echo "ANSIBLE-GALAXY: finding each collection installed and upgrading it..."
# # TODO: output the list of packages to file and then call --upgrade on
# # the new requirements file, prob faster that way
# Tested on Macbook Air 2020
# took 107 seconds to run when 219 ansible galaxy collections were installed
# LIST_OF_INSTALLED_ANSIBLE_COLLECTIONS=$(ansible-galaxy collection list | \
#      grep "\." | grep -v "^# " | cut -d ' '  -f1 | sort --unique)
# set +e    # temporarily tolerate errors
# while IFS= read -r ITER_COLLECTION ; do
#      # echo "DEBUG ======================================= $ITER_COLLECTION"
#      # there is no --quiet flag available
#      ansible-galaxy collection install "$ITER_COLLECTION" --upgrade
#      # ansible-galaxy collection verify  "$ITER_COLLECTION"
# done <<< "$LIST_OF_INSTALLED_ANSIBLE_COLLECTIONS"

# resume not tolerating errors
set -e

#ansible-galaxy collection verify  community.general
#ansible-galaxy collection verify  geerlingguy.mac

# upgrade ansible-lint

clear
# check the syntax of the playbook before running it
# the --ask-become-pass is important for OS X

# have to clean Python cache AGAIN b/c it often causes failures with Brew
# during the playbook run
clean_python_cache

echo "ANSIBLE-PLAYBOOK: Running playbook-osx-config.yml..."
ansible-lint     playbooks/playbook-osx-config.yml
ansible-playbook playbooks/playbook-osx-config.yml   --ask-become-pass -i "$INVENTORY_FILE"

echo "ANSIBLE-PLAYBOOK: Running playbook-osx-cleanup.yml..."
ansible-lint     playbooks/playbook-osx-cleanup.yml
ansible-playbook playbooks/playbook-osx-cleanup.yml  --ask-become-pass -i "$INVENTORY_FILE"

echo "run-ansible-osx.sh finished successfully."
