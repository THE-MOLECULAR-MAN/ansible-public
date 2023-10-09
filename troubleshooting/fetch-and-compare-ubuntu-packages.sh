#!/bin/bash
# Tim H 2022

# fetch and compare Ubuntu packages

WORKING_PATH="$HOME/tmp"

mkdir -p "$WORKING_PATH"
find "$WORKING_PATH" -type f -name 'apt-list_*.txt' -delete

./test-playbook.sh playbooks/playbook-ubuntu-list-packages.yml

cd "$WORKING_PATH" || exit 1

# golden has eatmydata but kubernetes does NOT have it
# shows what LEFT has that RIGHT lacks
diff --changed-group-format='%<' --unchanged-group-format='' apt-list_golden-ubuntu.txt apt-list_kubernetes2.txt

# reverse:
diff --changed-group-format='%<' --unchanged-group-format='' apt-list_idr-collector6.txt apt-list_golden-ubuntu.txt

# sudo apt-get -y purge cloud-guest-utils cloud-init eatmydata
