 ansible-playbook  -i inventory/hosts.yaml ./playbooks/docker.yaml --user=d3
 ansible-playbook -i inventory/komodo.yaml playbooks/komodo.yml --vault-password-file ~/.vault_pass -e "komodo_action=update" -e "komodo_version=latest"

ansible-playbook -i inventory/komodo.yaml playbooks/komodo.yml --vault-password-file ~/.vault_pass