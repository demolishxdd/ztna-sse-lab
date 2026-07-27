# 03 — Prisma Access & ZTNA Connector Deployment

## 📋 Overview
This document details the deployment and configuration of **Palo Alto Prisma Access** and the on-premises **ZTNA Connector VM** managed through **Strata Cloud Manager (SCM)**. The connector establishes inside-out, outbound-only encrypted tunnels to allow remote users to securely access private applications without exposing internal subnets.

---

## 🌐 1. Prisma Access Infrastructure Setup

Initial configuration was established within Strata Cloud Manager under the `Prisma Access` configuration scope:

### Core Network Address Allocation
| Parameter | Subnet / Address Range | Purpose |
| :--- | :--- | :--- |
| **Internal DNS Server (`DNS_SERVER1`)** | `192.168.50.3` | Local Domain Controller resolving internal `.lab.local` FQDNs. |
| **Internal Domain Name** | `lab.local` | Primary search domain for private application targets. |
| **Private Application Subnet** | `192.168.50.0/24` | Internal subnet housing GLPI, Zabbix, and core services. |
| **Connector Subnet (Outbound WAN)** | `10.10.10.0/24` | Dedicated subnet allocated for ZTNA Connector outbound transit. |

Following subnet and DNS definition, a **Push Config** operation was performed in SCM to synchronize infrastructure settings with the Prisma Access cloud processing nodes.

---

## 🔌 2. ZTNA Connector VM Deployment

The ZTNA Connector was deployed as an OVA virtual appliance on the VMware ESXi hypervisor host (`SRV1`).

```
+-----------------------------------------------------------------------------------+
|                        Two-Arm ZTNA Connector Architecture                        |
|                                                                                   |
|                   +-------------------------------------------+                   |
|                   |        Palo Alto Prisma Access            |                   |
|                   |         Cloud Processing Node             |                   |
|                   +-------------------------------------------+                   |
|                                         ^                                         |
|                                         | Outbound TLS/IPsec                        |
|                                         | Port 443 / 500 / 4500                     |
|                                         v                                         |
|  +-----------------------------------------------------------------------------+  |
|  |                     ZTNA Connector VM (Two-Arm OVA)                         |  |
|  |                                                                             |  |
|  |  +-----------------------------------+   +-------------------------------+  |  |
|  |  | WAN / Outbound Interface (NIC1)   |   | LAN Interface (NIC2)          |  |  |
|  |  | IP: 10.10.10.210/24               |   | IP: 192.168.50.211/24         |  |  |
|  |  | Default Gateway: 10.10.10.1      |   | Gateway: 0.0.0.0 (None)       |  |  |
|  |  | DNS: Upstream (10.10.10.1)       |   | Internal DNS: 192.168.50.3    |  |  |
|  |  +-----------------------------------+   +-------------------------------+  |  |
|  +-----------------------------------------------------------------------------+  |
|                                                                         |         |
|                                                                         v         |
|                                                            +-------------------+  |
|                                                            | Private Apps      |  |
|                                                            | (GLPI / Zabbix)   |  |
|                                                            +-------------------+  |
+-----------------------------------------------------------------------------------+
```

### Connector Group & Network Interface Layout
1. **Connector Group (`Group-1`):** Logical grouping created in SCM to manage connector instances, load balancing, and private app routing.
2. **Two-Arm Network Configuration:**
   * **WAN / Outbound Interface (NIC1):** Dedicated to outbound cloud tunnel communication. Configured with static IP `10.10.10.210/24` pointing to edge gateway `10.10.10.1`.
   * **LAN Interface (NIC2):** Dedicated to internal application traffic. Configured with static IP `192.168.50.211/24` with **no default gateway** (`0.0.0.0`) to avoid asymmetric routing. Points to local DNS `192.168.50.3`.

---

## 🎯 3. Private Application Target Definitions

Internal workloads were registered as **FQDN Targets** under `Group-1` inside Strata Cloud Manager:

| Application Name | FQDN Target | Protocol | Internal Target IP | Application Status |
| :--- | :--- | :---: | :--- | :---: |
| **GLPI Helpdesk** | `glpi.lab.local` | TCP | `192.168.50.4` | ✅ Up |
| **Zabbix Monitoring** | `zabbix.lab.local` | TCP | `192.168.50.5` | ✅ Up |

User access requests to these FQDNs are intercepted by the GlobalProtect Agent or Secure Agentless Access portal and routed securely through the ZTNA tunnel.

---

## 🛡️ 4. Identity-Aware Security Rules

Security policies were configured under the **Mobile Users Container – Pre Rules** section in SCM to enforce role-based access:

| Rule Name | Action | Source User / Group | Destination Target | Application / Ports | Description |
| :--- | :---: | :--- | :--- | :--- | :--- |
| `Allow-HR-Zabbix` | **Allow** | `cn=hr-users` | `Zabbix` (`192.168.50.5`) | `web-browsing`, `ssl` | HR department access to monitoring dashboard. |
| `Allow-IT-GLPI` | **Allow** | `cn=it-admins` | `GLPI` (`192.168.50.4`) | `web-browsing`, `ssl` | IT Admin access to ticketing & asset management. |
| `Allow-Directors` | **Allow** | `cn=directors` | `GLPI`, `Zabbix` | `web-browsing`, `ssl` | Executive full access to internal web applications. |
| `Deny-All-Internal`| **Deny** | `Any` | Internal Subnets (`192.168.50.0/24`) | `Any` | Implicit explicit drop for unauthorized internal traffic. |
