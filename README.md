# FreeIPA-CDP
FreeIPA installation and configuration for Cloudera environments

## Host pre-requisites

Update `utils/host-list.txt` with the full list of cluster hosts, including the FreeIPA server.

### Verify DNS

Ensure that forward and reverse DNS resolution is correctly configured for all hosts.
```bash
yum install -y bind-utils
chmod +x utils/verify_dns.sh
./utils/verify_dns.sh utils/host-list.txt
```

### Passwordless SSH configuration

Configure SSH key-based authentication to allow Ansible to access all nodes without passwords.
```bash
dnf install -y sshpass
ssh-keygen
```

Deploy the SSH keys and validate access:
```bash
chmod +x utils/deploy_keys.sh
./utils/deploy_keys.sh host-list.txt

chmod +x utils/check_access.sh
./utils/check_access.sh host-list.txt
```

## Ansible installation

Install Ansible and the required FreeIPA collection.
```bash
dnf install -y ansible-core git
ansible-galaxy collection install freeipa.ansible_freeipa
```

Edit `freeipa-deploy/inventory.yml` to define the FreeIPA server and client hosts, then verify connectivity:
```bash
cd freeipa-deploy
ansible -i inventory.yml all -m ping
```

## Playbook configuration

### Create an Ansible Vault for credentials

Create a vault file to securely store sensitive passwords.
```bash
ansible-vault create group_vars/ipa_cluster/vault.yml
```

Add the following variables:
```bash
vault_ipa_admin_password: "<STRONG_ADMIN_PASSWORD>"
vault_ipa_dm_password: "<STRONG_DIRECTORY_MANAGER_PASSWORD>"
```

### Cluster configuration

Edit `group_vars/ipa_cluster/ipacluster.yml` and adjust the values to match your environment:
```bash
# DNS / LDAP domain
ipaserver_domain: cloudera.com

# Kerberos realm (Cloudera)
ipaserver_realm: CLOUDERA.COM

# Certificate Authority subject
ipaserver_ca_subject: "CN=IPA CA,O=CLOUDERA,L=Paris,C=FR"
```

Also ensure that inventory.yml correctly reflects your cluster topology.

Edit the inventory.yml

## Running the playbook

### FreeIPA server deployment

Run the playbook on the FreeIPA server:
```bash
ansible-playbook playbooks/ipa-server.yml --ask-vault-pass
```

Verification :
```bash
kinit admin
klist
ipa config-show
```
Expected result:
- Successful Kerberos authentication as `admin@<REALM>`
- FreeIPA configuration displayed without errors

### FreeIPA client deployment

Deploy FreeIPA clients on all remaining nodes:
```bash
ansible-playbook playbooks/ipa-client.yml --ask-vault-pass
```

Verification :
```bash
ipa host-find
```
Expected result:
- All client hosts are listed

From a client node :
```bash
id admin
kinit admin
klist
systemctl status sssd
```
Expected result:
- User resolution works
- Kerberos ticket is obtained successfully
- SSSD service is running

## Web UI access 
Access the FreeIPA web interface at `https://<ipa-server>:443`
