# Cloudera Auto-TLS

Once Cloudera Manager Server is installed, you should have below screen, for SSL/TLS and KDC configuration.

<img width="1911" height="952" alt="image" src="https://github.com/user-attachments/assets/d7aad070-c923-425b-b894-956b67f3e124" />

The IPA installation has deployed the file ca.crt on all hosts /etc/ipa/ca.crt
You can verify
```
openssl x509 -in /etc/ipa/ca.crt -noout -subject -issuer
```

Should match what you put in freeipa-deploy/group_vars/ipacluster/main.yml
```
# CA subject
ipaserver_ca_subject: "CN=IPA CA,O=CLOUDERA,L=Perth,C=AU"
```


Thus you can use it :

<img width="1906" height="951" alt="image" src="https://github.com/user-attachments/assets/823d3d66-ff1a-49f4-9862-0762768f69ed" />

Whats it does : 
- Cloudera Manager generates an CSR
- This CSR is signed by the IPA CA you defined
- Provide chain

https://docs.cloudera.com/cdp-private-cloud-base/7.3.1/security-encrypting-data-in-transit/topics/cm-security-use-case-2.html

Then restart

```
systemctl restart cloudera-scm-server
```

Go to UI : 
https://<cloudera-manager-server>:7183

<img width="1905" height="954" alt="image" src="https://github.com/user-attachments/assets/e2b5f3f8-24ee-4b97-93d5-18582fd62590" />

TLS is set up !
