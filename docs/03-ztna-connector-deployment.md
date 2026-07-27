# 03 — Prisma Access & ZTNA Connector Deployment

## 📋 Overview
This document details the deployment and configuration of **Palo Alto Prisma Access** and the on-premises **ZTNA Connector VM** managed through **Strata Cloud Manager (SCM)**[cite: 1]. The connector establishes inside-out, outbound-only encrypted tunnels to allow remote users to securely access private applications without exposing internal subnets to the public internet[cite: 1].

---

## 🌐 1. Prisma Access Infrastructure Setup

Initial configuration was established within Strata Cloud Manager under the `Prisma Access` configuration scope[cite: 1]:

### Core Network Address Allocation
| Parameter | Subnet / Address Range | Purpose |
| :--- | :--- | :--- |
| **Internal DNS Server (`DNS_SERVER1`)** | `192.168.50.3` | Local Domain Controller resolving internal `.lab.local` FQDNs[cite: 1]. |
| **Internal Domain Name** | `lab.local` | Primary search domain for private application targets[cite: 1]. |
| **Application Anycast IP Block** | `10.240.240.0/24` | Synthetic IP block assigned by Prisma Access for application routing[cite: 1]. |
| **Connector IP Block** | `10.240.241.0/24` | Subnet pool allocated for ZTNA Connector fabric addressing[cite: 1]. |

Following subnet and DNS definition, a **Push Config** operation was performed in SCM to synchronize infrastructure settings with the Prisma Access cloud processing nodes[cite: 1].

---

## 🔌 2. ZTNA Connector VM Deployment

The ZTNA Connector was deployed as an OVA virtual appliance on the VMware ESXi hypervisor host (`SRV1`)[cite: 1].
