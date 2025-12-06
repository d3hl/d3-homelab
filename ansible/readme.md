 ansible-playbook  -i inventory/hosts.yaml ./playbooks/docker.yaml --user=d3
ansible-playbook -i inventory/hosts playbooks/cisco/add-vlans.yaml -k
 
 ansible-playbook -i inventory/komodo.yaml playbooks/komodo.yml --vault-password-file ~/.vault_pass

 # When run Komodo with Rootless Dockerrj 
systemctl --user stop docker
systemctl --user stop periphery.service 
sudo ln -s /var/run/user/1000/docker.sock /var/run/docker.sock
systemctl --user start docker
systemctl --user start periphery.service