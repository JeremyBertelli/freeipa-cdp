# freeipa-cdp
FreeIPA installation and configuration for Cloudera

## Host pre-requisites

Modify the utils/host-list with the list of all the hosts of your cluster (including IPA server)

### Verify DNS

```bash
yum install bind-utils -y
chmod +x utils/verify_dns.sh
./utils/verify_dns.sh host-list.txt
```
### Configure passwordless ssh
```bash
dnf install -y sshpass
ssh-keygen

chmod +x utils/deploy_keys.sh
./utils/deploy_keys.sh host-list.txt

chmod +x utils/check_access.sh
./utils/check_access.sh host-list.txt
```

## Ansible installation
```bash
dnf install -y ansible-core git
ansible-galaxy collection install freeipa.ansible_freeipa
```

Modify freeipa-deploy/inventory.yml for your cluster with ipa server and clients ; then check connectivity with ansible

```
cd freeipa-deploy
ansible -i inventory.yml all -m ping
```

## Configuring the playbook

### Create vault for your password
```
ansible-vault create group_vars/ipa_cluster/vault.yml
```

```
vault_ipa_admin_password: "<STRONG_ADMIN_PASSWORD>"
vault_ipa_dm_password: "<STRONG_DIRECTORY_MANAGER_PASSWORD>"
```



### Configuration

Edit file group_vars/ipa_cluster/ipacluster.yml
```
# DNS / LDAP domain
ipaserver_domain: perth.root.comops.site

# Kerberos realm (Cloudera)
ipaserver_realm: CLOUDERA.COM

# CA subject
ipaserver_ca_subject: "CN=IPA CA,O=CLOUDERA,L=Perth,C=AU"
```

Edit the inventory.yml

## Running the playbook

### IPA Server

```
ansible-playbook playbooks/ipa-server.yml --ask-vault-pass
```

Verify

```bash

kinit admin
klist
ipa config-show

```

Expected output being able to kinit as admin@<REALM.COM> and see the configuration

### IPA Clients

```bash
ansible-playbook playbooks/ipa-clients.yml --ask-vault-pass
```

Verify
From the server : 
```
ipa host-find
```
Expected the list of all the clients nodes


From a client : 
```
id admin
kinit admin
klist
systemctl status sssd --no-pager
```
Expected

```bash
some stuff
```


## UI

https://<ipa-server>:443


