# KDC

Once TLS is set up : 

<img width="1905" height="954" alt="image" src="https://github.com/user-attachments/assets/a9fcce6e-57d5-4403-a1e7-3e7ef047b983" />

Install required packages, you can use the dedicated script : 
```
chmod +x utils/install_ipa_tools.sh
./utils/install_ipa_tools.sh utils/host-list.txt 
```

One done, Select KDC Type : Red Hat IPA and tick the box "I have completed all the above steps."

<img width="1908" height="953" alt="image" src="https://github.com/user-attachments/assets/3a12d74c-13d4-46b0-af13-a58eae836bef" />

Fill the informations : 
- default_realm : CLOUDERA.COM must match the # Kerberos realm (Cloudera) ipaserver_realm: CLOUDERA.COM from main.yml
- KDC and admin server to your IPA host
<img width="1904" height="958" alt="image" src="https://github.com/user-attachments/assets/d8cd3f78-0e64-42b7-ad47-7cb64a44de71" />


## krb5 configuration 

aes256-cts-hmac-sha1-96
aes128-cts-hmac-sha1-96
aes256-cts-hmac-sha384-192
aes128-cts-hmac-sha256-128

Tick krb_manage_krb5_conf flag.

<img width="1917" height="957" alt="image" src="https://github.com/user-attachments/assets/d2254bb8-2a3e-44a5-ba33-6acb023a238a" />



## KDC admin user import

Use default admin user  

<img width="1909" height="344" alt="image" src="https://github.com/user-attachments/assets/d678e057-1cdf-41df-8b91-49d23f9d0741" />

will create a cmadmin-<uid> That will create principals and everything needed.

<img width="1911" height="601" alt="image" src="https://github.com/user-attachments/assets/8da8ff67-e2f8-448d-8700-ecb748ab1f0a" />


Finally, KDC is set up and you can proceed to the install of a secured cluster !



