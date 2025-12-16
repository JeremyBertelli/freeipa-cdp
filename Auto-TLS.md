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

## Enabling Auto-TLS with an intermediate CA signed by an existing Root CA

### How it works

When Auto-TLS is enabled in Cloudera Manager, the following steps occur automatically:
- Cloudera Manager generates a Certificate Signing Request (CSR)
  - A CSR is created for each service and host
  - Each CSR contains the host identity (hostname, SANs, etc.)
- The CSR is sent to the FreeIPA Certificate Authority
  - Cloudera Manager uses the trusted CA ; here using the FreeIPA CA `/etc/ipa/ca.crt
  - FreeIPA signs the certificates using the internal IPA CA
- Certificates and trust chain are distributed automatically
  - Signed certificates are installed on all Cloudera services
  - The full certificate chain (leaf + CA) is configured
  - No manual keystore or truststore management is required
- TLS is enabled cluster-wide
  - All internal service-to-service communication is encrypted
  - Web UIs and APIs are protected with HTTPS

This process is fully automated and follows the Cloudera reference architecture described here: [Enabling Auto-TLS with an intermediate CA signed by an existing Root CA](https://docs.cloudera.com/cdp-private-cloud-base/7.1.9/security-encrypting-data-in-transit/topics/cm-security-use-case-2.html)

### How to do it

Set the Trusted CA Certificates Location to the FreeIPA CA certificate: `/etc/ipa/ca.crt`.
Cloudera Manager will trust this CA to sign all TLS certificates.

Select Enabling TLS for all existing and future clusters to enable TLS immediately on the current cluster and all future ones.

<img width="1906" height="951" alt="image" src="https://github.com/user-attachments/assets/823d3d66-ff1a-49f4-9862-0762768f69ed" />

After completing the Auto-TLS configuration, restart Cloudera Manager:
```bash
systemctl restart cloudera-scm-server
```

Then access the Cloudera Manager UI: `https://<cloudera-manager-server>:7183`

<img width="1905" height="954" alt="image" src="https://github.com/user-attachments/assets/e2b5f3f8-24ee-4b97-93d5-18582fd62590" />

At this point, TLS is fully enabled, and all Cloudera services are secured using certificates issued by your FreeIPA CA.
