#!/bin/bash
# Tim H 2022

# Installs and configures Ansible software on a fresh Ubuntu VM
# Downloads my Ansible GitHub repository, designed to be run on schedule

# converted original script from CentOS 7 to Ubuntu 20.04
# CentOS has fallen too far behind on Python, Pip, Ansible.

# copy over SSH private key and stuff from regular laptop to new
# Ansible controller so it can login to target systems.
scp "$HOME"/.ssh/config      cronuser@cron-runner2.int.butters.me:~/.ssh/
scp "$HOME"/.ssh/thonker.adm cronuser@cron-runner2.int.butters.me:~/.ssh/
# also had to delete a few lines from the .ssh/config file that worked in OSX
# but not in Linux

# upgrade Ubuntu 20.04 to latest LTS?
# shutdown and take a snapshot first
# sudo do-release-upgrade

###############################################################################
#   ON THE NEW ANSIBLE CONTROLLER:
###############################################################################

# install GitHub and new GH repo for Ubuntu
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt-get update
sudo apt-get -y install gh

# seems to be required for Ubuntu 20.04?
sudo apt-get -y install python3.10

# https://www.rosehosting.com/blog/how-to-install-and-switch-python-versions-on-ubuntu-20-04/#Step-4-Change-Python-Version
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1

# select Python 3.10 as the new default:
sudo update-alternatives --config python

# install dependencies
sudo python3.10 -m pip install --upgrade pip ansible-lint ansible

# Upgrading PIP to latest version
# yes, the sudo version is required
# sudo pip3 install --upgrade pip

# Install Ansible and yamllint utility
# sudo apt-get -y install ansible yamllint ansible-lint
# pip3 install ansible ansible-lint
# pip3 install --user --upgrade ansible-lint
ansible        --version
ansible-galaxy --version
ansible-lint   --version
ansible-galaxy collection install ansible.posix community.general

# https://github.com/GitCredentialManager/git-credential-manager/blob/main/docs/environment.md#gcm_credential_store
# https://www.redhat.com/sysadmin/management-password-store
# TODO: make it work with crontab
echo "
export GCM_CREDENTIAL_STORE=plaintext
PATH="$HOME/.local/bin:$PATH"
" >> "$HOME"/.bash_profile

# shellcheck disable=SC1091
source "$HOME"/.bash_profile

# install Git Credential Manager
# https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-raspberry-pi-os-apt
# wget "https://github.com/GitCredentialManager/git-credential-manager/releases/download/v2.0.785/gcm-linux_amd64.2.0.785.deb"
# sudo dpkg -i gcm-linux_amd64.2.0.785.deb
# git-credential-manager-core configure

# Login to GitHub and download my ansible repository
cd "$HOME" || exit 2
gh repo clone THE-MOLECULAR-MAN/ansible-public

cd "$HOME/ansible" || exit 4
# test persisent auth, make sure future git pulls will work
git pull

# install various dependencies before first run
ansible-galaxy collection install -r requirements.yml --force

# run a test set of playbooks
./run-ansible-ubuntu.sh
