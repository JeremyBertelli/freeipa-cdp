# FreeIPA for Cloudera CDP (Kerberos + Auto-TLS)

## Overview

In a Cloudera CDP environment, cluster security relies on two core components:
- Kerberos for authentication
- TLS for encrypting data in transit

When no enterprise KDC or PKI is available (or reachable from the cluster), or when the goal is to decouple the CDP cluster from the corporate Active Directory, FreeIPA is a practical solution.

This repository provides a simple and reproducible approach to deploy a FreeIPA instance dedicated to a single CDP cluster, and to use it as:
- the Kerberos KDC for CDP
- the Certificate Authority (CA) used by Cloudera Manager Auto-TLS

## What this project covers

- FreeIPA installation
  - FreeIPA server and clients deployment using Ansible FreeIPA
  - Basic configuration adapted to a Cloudera CDP environment
- Cloudera CDP Authentication with Kerberos configuration using FreeIPA
- Cloudera CDP Auto-TLS configuration with an intermediate CA signed by FreeIPA CA

### Environment

Tested on : 
- RHEL 8.10
- Cloudera Manager 7.13.1-500

### Disclaimer

This repository reflects a field-driven setup based on real CDP environments.  
It does not replace official Cloudera documentation and should be reviewed and adapted before production use.

## TODO

- Documentation to enable FreeIPA Kerberos cross-realm trust with enterprise AD
