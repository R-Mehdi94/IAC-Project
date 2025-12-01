Password Vault : ansible

#  Projet Infrastructure as Code -- KapsuleKorp

**Terraform + Ansible -- Déploiement LEMP (Linux / Nginx / MySQL /
PHP)**

##  Objectif du projet

Ce projet a pour but d'automatiser la création et la configuration
complète d'une infrastructure web LEMP destinée à héberger l'application
**KapsuleKorp** en deux environnements :

-   **Staging**
-   **Production**

Le déploiement est réalisé via :

-   **Terraform** → Provision des machines virtuelles + réseau +
    firewall
-   **Ansible** → Configuration LEMP + déploiement de l'application

##  Architecture générale

    terraform/            → Provisioning infrastructure (VM, firewall, inventaire)
    roles/
       common/            → Configuration système commune
       mysql/             → Installation & configuration MySQL
       nginx/             → Installation & configuration Nginx
       php/               → Installation PHP-FPM + déploiement app
    site.yml              → Playbook Ansible principal
    group_vars/           → Variables d’environnement par groupe  (vault)
    host_vars/            → Variables d’environnement par machine (vault)
    ansible.cfg           → Configuration Ansible
    inventory.ini         → Généré automatiquement par Terraform

## ☁️ 1. Infrastructure -- Terraform

Terraform crée automatiquement :

-   2 machine  web **staging**
-   1 serveur DB **staging**
-   3 machine serveur web **production**
-   1 serveur DB **production**
-   Une règle firewall autorisant le port **80-443-81** pour tout sur les machine web
-   Une règle firewall autorisant le port **3306** uniquement entre web
    → db
-   Un fichier **inventory.ini** automatiquement utilisé par Ansible

### Commandes Terraform

``` bash
cd terraform
terraform init
terraform plan
terraform apply
```

## 2. Configuration -- Ansible

Le playbook `site.yml` applique automatiquement 4 rôles :

    common  → Configuration système
    mysql   → Serveur MySQL + DB + user
    nginx   → Serveur web + vhost
    php     → PHP-FPM + application KapsuleKorp

### Commande d'exécution

``` bash
ansible-playbook -i inventory.ini site.yml --ask-vault-pass
```

##  3. Description des rôles

###  Rôle : common

-   Update système
-   Timezone Europe/Paris
-   Installation packages  
-   Installation PyMySQL sur DB

###  Rôle : mysql

-   Installation MySQL
-   Création DB + user
-   Configuration Root (vault)
 

###  Rôle : nginx

-   Installation Nginx
-   Suppression configuration par défaut
-   Vhost custom : port 81 + PHP-FPM

###  Rôle : php

-   Installation PHP-FPM
-   Modules PHP
-   Pool personnalisé
-   Déploiement app KapsuleKorp

##  4. Gestion des secrets -- Ansible Vault

Créer des fichiers chiffré (db_vault.yml- app_vault.yml) dans chaque environnement :

 group_vars/staging
 group_var/production
 



##  5. Workflow de déploiement

    1. terraform apply
    2. ansible-playbook -i inventory.ini site.yml --ask-vault-pass
    3. IP_WEB:81

 
