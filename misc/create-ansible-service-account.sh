#!/bin/bash
# Tim H 2022

# Create Ansible service account infrastructure
# Create the user svc-ansible in Active Directory, save the password in LastPass. 
#   Limit the special characters used in the password to avoid escape characters like / and \ and " "
# Create an AD security group called "localadmins". Don't use spaces or any special symbols
# add the svc-ansible user to the localadmins AD group

# create an SSH 

SERVICE_ACCOUNT_NAME="svc-ansible"
SERVICE_ACCOUNT_DOMAIN="INT.BUTTERS.ME"

cd "$HOME/.ssh" || exit 1

ssh-keygen -t ecdsa -b 256 -f "$HOME/.ssh/$SERVICE_ACCOUNT_NAME"  -N "" -C "$SERVICE_ACCOUNT_NAME@$SERVICE_ACCOUNT_DOMAIN"

cat "$HOME/.ssh/$SERVICE_ACCOUNT_NAME.pub"

#### on target systems, test

sudo su - "$SERVICE_ACCOUNT_NAME@$SERVICE_ACCOUNT_DOMAIN" -c "mkdir ~/.ssh && chmod 755 ~/.ssh && echo \"\" >> ~/.ssh/authorized_keys && chmod 644 ~/.ssh/authorized_keys"

sudo su - "svc-ansible@INT.BUTTERS.ME" -c "mkdir ~/.ssh && chmod 755 ~/.ssh && echo \"ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBF7r50xpk6UkIhNvUAGxuaPAAesYRy47iQG/K96ANFoWVQFY5CJIGyq7lK7IWRFRXeCjEgxmBsm5Rz/yK3DsOwo= svc-ansible@INT.BUTTERS.ME\" >> ~/.ssh/authorized_keys && chmod 644 ~/.ssh/authorized_keys"
