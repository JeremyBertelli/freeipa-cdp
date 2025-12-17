# Cloudera Auto-TLS with FreeIPA

Once Cloudera Manager Server is installed, the initial setup wizard prompts you to configure TLS/SSL and KDC (Kerberos) integration.

At this stage, Cloudera Manager can leverage the FreeIPA Certificate Authority (CA) to automatically secure all internal communications.

<img width="1911" height="952" alt="image" src="https://github.com/user-attachments/assets/d7aad070-c923-425b-b894-956b67f3e124" />

## FreeIPA CA 

During the FreeIPA installation, the CA certificate is deployed on all hosts at the location `/etc/ipa/ca.crt`.
You can verify the certificate subject and issuer with:
```bash
openssl x509 -in /etc/ipa/ca.crt -noout -subject -issuer
```

The output must match the CA subject defined in your FreeIPA configuration:
```
# CA subject
ipaserver_ca_subject: "CN=IPA CA,O=CLOUDERA,L=Paris,C=FR"
```

If the subject matches, Cloudera Manager can safely trust this CA for TLS operations.

## Use Cloudera Manager to generate internal CA and corresponding certificates

### How it works

This process is fully automated and follows the Cloudera reference architecture described here: [Use Cloudera Manager to generate internal CA and corresponding certificates](https://docs.cloudera.com/cdp-private-cloud-base/7.1.9/security-encrypting-data-in-transit/topics/cm-security-use-case-1.html)

### How to do it

Set the Trusted CA Certificates Location to the FreeIPA CA certificate: `/etc/ipa/ca.crt`.
Cloudera Manager will trust this CA to sign all TLS certificates.

<img width="1906" height="951" alt="image" src="https://github.com/user-attachments/assets/823d3d66-ff1a-49f4-9862-0762768f69ed" />

After completing the Auto-TLS configuration, restart Cloudera Manager:
```bash
systemctl restart cloudera-scm-server
```

Then access the Cloudera Manager UI: `https://<cloudera-manager-server>:7183`

<img width="1905" height="954" alt="image" src="https://github.com/user-attachments/assets/e2b5f3f8-24ee-4b97-93d5-18582fd62590" />

### Local cloudera-scm-agent

After enabling TLS, the local Cloudera Manager agent on the server host may fail to start with the following error in `/var/log/cloudera-scm-agent/cloudera-scm-agent.log`:
```
M2Crypto.SSL.Checker.WrongHost: Peer certificate subjectAltName does not match host,
expected localhost, got DNS:<hostname>
```

To fix this, edit the agent configuration file: `/etc/cloudera-scm-agent/config.ini`
Update the following parameter: `server_host=localhost` to the fully qualified hostname of the Cloudera Manager server.

Then restart the agent:
```
systemctl restart cloudera-scm-agent
****

Agents installed after TLS is enabled will be correctly configured automatically.

At this point, TLS is fully enabled, and all Cloudera services will be secured using certificates issued by your FreeIPA CA.
