#!/bin/bash
# Tim H 2022

# the ansible script will prompt for other things like new hostname,
# domain admin creds

set -e

target_fqdn="$1"
new_inventory_path="inventories/to_join_domain.txt"
orig_inventory_path="inventories/ansible-hosts.homelab"

# dependency to simplify bash code for prepend
# brew install moreutils

# make a backup of SSH config before making changes
cp -f ~/.ssh/config ~/.ssh/config.backup

# prepend SSH config to beginning of text file
echo "#DELETABLE_START
Host $target_fqdn
   User thrawn
   IdentityFile ~/.ssh/thonker.adm
   PreferredAuthentications publickey
#DELETABLE_END

" | cat - ~/.ssh/config | sponge ~/.ssh/config

# make sure I can SSH into it w/o interactive
# returns error code of 255 for failed login
# sends single command, no psuedoterminal or interactive session
ssh -T "$target_fqdn" "whoami"

echo "[to_join_domain]
$target_fqdn
" > "$new_inventory_path"

# set the hostname first:
# -i is required here:
ansible-playbook ./playbooks/playbook-change-hostname.yml -i "$new_inventory_path" --extra-vars "new_fqdn_hostname=$target_fqdn"

# check syntax before running:
ansible-lint     ./playbooks/playbook-ubuntu-join-domain.yml

# join it to the domain
ansible-playbook ./playbooks/playbook-ubuntu-join-domain.yml -i "$new_inventory_path"

# add it to the ansible inventory
# must use gsed in OS X, not sed
# working inline replacement with IP
gsed -i "/\[debian_family\].*/a $target_fqdn" "$orig_inventory_path"

ansible-playbook playbooks/playbook-ubuntu-baseline.yml -i "$orig_inventory_path" --limit "$target_fqdn"
ansible-playbook playbooks/playbook-ubuntu-domained.yml -i "$orig_inventory_path" --limit "$target_fqdn"
ansible-playbook playbooks/playbook-ubuntu-agents.yml   -i "$orig_inventory_path" --limit "$target_fqdn"

# ssh key drop isn't working
# TODO: test regular SSH key auth and priv esc via local command line
# TODO: add hostname as bash variable, pass to ansible somehow
# consider waiting until things are safe like agent activations or just timer
#   then shutdown/halt to prepare for vSphere snapshot

# clean up:
rm -f "$new_inventory_path"

echo "join-system-to-domain.sh Script finished successfully."

# public keys aren't added.
# domain admins not sudoers
