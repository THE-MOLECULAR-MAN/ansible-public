#!/bin/bash
# Tim H 2022

# Purge ansible and all it's cached files and logs

# https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#pip-upgrade

# must tolerate errors since the uninstall command will throw error if something is not installed
set +e

env | grep -i python

# be really careful about this
#rm /private/etc/paths.d/*

# turns out I had multiple versions of ansible installed via different package managers
#brew list | grep ansible
#brew list --cask | grep ansible

# purge any old install
ls -lah "$(whereis pip  | cut -d ' ' -f2-)"
ls -lah "$(whereis pip3 | cut -d ' ' -f2-)"

pip  uninstall -y ansible ansible-base
#pip3 uninstall -y ansible ansible-base
brew uninstall    ansible ansible-base

whereis ansible

pip3 cache purge
brew cleanup --prune=0
brew cleanup -s

sudo rm -Rf /private/etc/ansible /usr/local/bin/ansible "$HOME/Library/Logs/Homebrew/ansible" "$HOME/.cache/ansible-lint"
sudo rm -Rf "$HOME/.ansible" /usr/share/ansible /Library/Frameworks/Python.framework/Versions/3.9/lib/python3.9/site-packages/ansible /Library/Frameworks/Python.framework/Versions/3.9/bin/ansible

whereis ansible

find "$HOME" -iname '*ansible*' 2>/dev/null

#"$HOME/Library/Caches/com.apple.python/Users/tim/Library/Python/3.8/"

# https://stackoverflow.com/questions/3819449/how-to-uninstall-python-2-7-on-a-mac-os-x-10-6-4

# Check for NodeJS modules
cd ~/Documents/no_backup/npm || exit 1
npm list | grep -i ansible


rm -f /Library/Frameworks/Python.framework/Versions/3.9/bin/ansible*

find /Library/Frameworks/Python.framework/Versions/ -iname '*ansible*' 2>/dev/null 

sudo rm -Rf /Library/Frameworks/Python.framework/Versions/3.9/lib/python3.9/site-packages/ansible_test /Library/Frameworks/Python.framework/Versions//3.9/lib/python3.9/site-packages/ansible_core-2.12.5.dist-info /usr/share/zsh/5.8.1/functions/ /usr/share/zsh/5.8.1/functions/_ansible  /System/Volumes/Data/usr/share/zsh/5.8.1/functions/_ansible  /System/Volumes/Data/opt/vagrant/ /opt/vagrant

find / -mount -iname '*ansible*' 2>/dev/null

echo "purge-ansible-osx.sh finished successfully."
