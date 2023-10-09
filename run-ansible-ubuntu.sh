#!/bin/bash
# Tim H 2022
# Run Ubuntu/Debian Ansible playbooks
set +e

./test-playbook.sh playbooks/playbook-ubuntu-connectivity-test.yml
./test-playbook.sh playbooks/playbook-ubuntu-baseline.yml
./test-playbook.sh playbooks/playbook-ubuntu-domained.yml
./test-playbook.sh playbooks/playbook-ubuntu-agents.yml
./test-playbook.sh playbooks/playbook-ubuntu-cleanup.yml

./test-playbook.sh playbooks/playbook-ubuntu-remove-unused-agents.yml

echo "run-ansible-ubuntu.sh Script finished successfully."
