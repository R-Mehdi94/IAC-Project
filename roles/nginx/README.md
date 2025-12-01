 

Ce projet vise à déployer automatiquement une application PHP/MySQL appelée KapsuleKorp dans deux environnements :

Staging

Production

Grâce à deux outils :

Terraform → crée l’infrastructure (VM, firewall, réseau…)

Ansible → configure les serveurs (Nginx, PHP, MySQL) + déploie l'application

##1. Architecture du projet
terraform/           → Provision des VM et firewall sur GCP
roles/
   common/           → Configuration système de base
   mysql/            → Installation + config MySQL
   nginx/            → Installation + configuration Nginx
   php/              → PHP-FPM + déploiement de l’application
group_vars/          → Variables par environnement (vault)
host_vars/           → Secrets propres à chaque serveur (vault)
site.yml             → Playbook principal Ansible
ansible.cfg          → Config Ansible
inventory.ini        → Généré automatiquement par Terraform

☁️ 2. Infrastructure (Terraform)

Terraform crée :

2 machines web (prod/staging)

2 machines db (prod/staging)

Une règle firewall :

Les web peuvent joindre les db sur MySQL (3306)

Un inventory.ini pour Ansible (automatique)

Commandes Terraform
cd terraform
terraform init
terraform apply -auto-approve


Une fois terminé, Terraform génère un fichier inventory.ini.

🛠️ 3. Configuration (Ansible)

Le playbook principal site.yml applique 4 rôles :

common → configuration système

mysql → installation MySQL / création DB + user

nginx → installation / configuration du vhost

php → installation PHP-FPM / pools / déploiement de l'app

📦 4. Description rapide des rôles
🔧 Rôle “common”

Applique les réglages communs à tous les serveurs :

Update système (apt dist-upgrade)

Change timezone → Europe/Paris

Installe packages utiles : git, htop, ufw, python3-pip

Installe PyMySQL sur les serveurs DB pour Ansible

🗄️ Rôle “mysql”

Concerne uniquement les serveurs de base de données.

Il :

installe MySQL Server

démarre et active le service

crée :

la base de données

l’utilisateur applicatif

le fichier /root/.my.cnf pour permettre à Ansible de se connecter sans mot de passe

applique le mot de passe root (via vault)

🌐 Rôle “nginx”

Sur les serveurs web :

installe Nginx

supprime la conf par défaut

déploie une conf dédiée :

écoute sur port 81

docroot → /var/www/kapsulekorp

envoi des .php vers PHP-FPM

active le site + reload Nginx

🐘 Rôle “php”

Sur les serveurs web :

installe PHP-FPM

installe les modules nécessaires (définis dans les variables)

désactive le pool par défaut

crée un pool spécifique pour l’application

déploie l'application :

/var/www/kapsulekorp/index.php

test de connexion MySQL

retour visuel "KapsuleKorp - Deployment successful"

🔐 5. Gestion des secrets (Ansible Vault)

Les mots de passe DB, root MySQL, etc. sont dans :

group_vars/staging/*.yml
host_vars/*/*.yml


Tous sont chiffrés avec Ansible Vault.

Commandes utiles

Créer un vault :

ansible-vault create group_vars/staging/db_vault.yml


Éditer :

ansible-vault edit group_vars/staging/db_vault.yml


Exécuter le playbook avec vault :

ansible-playbook -i inventory.ini site.yml --ask-vault-pass

🚀 6. Déploiement complet (résumé)
1️⃣ Provisionner l’infrastructure (Terraform)
cd terraform
terraform init
terraform apply


→ Les VM sont créées
→ L’inventory Ansible est généré

2️⃣ Exécuter Ansible
ansible-playbook -i inventory.ini site.yml --ask-vault-pass


Tous les rôles sont appliqués automatiquement.

3️⃣ Tester l’application

Ouvrir :

http://IP_DU_SERVEUR_WEB:81/


Tu devrais voir :

✔ Déploiement réussi
✔ Environnement (staging ou production)
✔ Version du serveur MySQL
✔ Connexion DB OK

📝 7. Commandes globales (récap rapide)
Terraform
terraform init
terraform plan
terraform apply
terraform destroy

Ansible
ansible-playbook -i inventory.ini site.yml
ansible-vault create fichier.yml
ansible-vault edit fichier.yml
ansible-vault encrypt fichier.yml