# KDC Configuration with FreeIPA

Once TLS is enabled, proceed with the Kerberos (KDC) configuration.

<img width="1905" height="954" alt="image" src="https://github.com/user-attachments/assets/a9fcce6e-57d5-4403-a1e7-3e7ef047b983" />

## Install required packages
Install the FreeIPA client tools on all hosts. You can use the provided script:
```bash
chmod +x utils/install_ipa_tools.sh
./utils/install_ipa_tools.sh utils/host-list.txt 
```

## Select KDC Type

In Cloudera Manager, select Red Hat IPA as the KDC type and check “I have completed all the above steps.”

<img width="1908" height="953" alt="image" src="https://github.com/user-attachments/assets/3a12d74c-13d4-46b0-af13-a58eae836bef" />

## KDC settings

Fill in the following values:
- Default realm: `CLOUDERA.COM` (Must match `ipaserver_realm` defined in `main.yml`)
- KDC server: FreeIPA server hostname
- Admin server: FreeIPA server hostname

Configure the following encryption types:
```bash
aes256-cts-hmac-sha1-96
aes128-cts-hmac-sha1-96
aes256-cts-hmac-sha384-192
aes128-cts-hmac-sha256-128
```

<img width="1907" height="955" alt="image" src="https://github.com/user-attachments/assets/773a7786-e72e-4b2b-8fa3-8025c248d331" />

## krb5 configuration

Enable the Manage krb5.conf option.

<img width="1902" height="952" alt="image" src="https://github.com/user-attachments/assets/f5f874db-c459-40fa-b341-dd811080a10b" />

## KDC admin user import

Use the default admin user.

<img width="1909" height="344" alt="image" src="https://github.com/user-attachments/assets/d678e057-1cdf-41df-8b91-49d23f9d0741" />

Cloudera Manager will automatically create a dedicated Kerberos admin principal (`cmadmin-<uid>`) to manage service principals and keytabs.

<img width="1911" height="601" alt="image" src="https://github.com/user-attachments/assets/8da8ff67-e2f8-448d-8700-ecb748ab1f0a" />

Finally, KDC is set up and you can proceed to the install of a secured cluster !

<img width="1904" height="955" alt="image" src="https://github.com/user-attachments/assets/5d11ce0d-5290-48b4-9e34-8e9ae52ab8eb" />




