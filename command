

ansible-playbook -i inventory.ini site.yml --ask-vault-pass
ansible-vault create group_vars/staging/db_vault.yml
