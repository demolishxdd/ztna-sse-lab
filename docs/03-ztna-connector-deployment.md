# 03 — Prisma Access & ZTNA Connector Deployment

## 📋 Overview
This document details the deployment and configuration of **Palo Alto Prisma Access** and the on-premises **ZTNA Connector VM** managed through **Strata Cloud Manager (SCM)**. The connector establishes inside-out, outbound-only encrypted tunnels to allow remote users to securely access private applications without exposing internal subnets.

---

## 🌐 1. Prisma Access Infrastructure Setup

Initial configuration was established within Strata Cloud Manager under the `Prisma Access` configuration scope:

### Core Network Infrastructure Definition
| Parameter | Configuration Scope | Purpose |
| :--- | :--- | :--- |
| **Internal DNS Profile** | `Internal-DC-DNS` | Resolves internal `.lab.local` FQDNs for corporate resources. |
| **Internal Search Domain** | `lab.local` | Primary search domain for private application targets. |
| **Private Application Scope** | `Internal-App-Segment` | Logical network hosting internal web services and monitoring platforms. |
| **Connector Transit Scope** | `ZTNA-WAN-Segment` | Dedicated transit network allocated for ZTNA Connector outbound traffic. |

Following network and DNS definition, a **Push Config** operation was performed in SCM to synchronize infrastructure settings with the Prisma Access cloud processing nodes.

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
|  |  | IP Assignment: Static WAN IP      |   | IP Assignment: Static LAN IP  |  |  |
|  |  | Default Gateway: Edge Router      |   | Gateway: None (0.0.0.0)       |  |  |
|  |  | DNS: Upstream Gateway DNS         |   | Internal DNS: Local DC DNS    |  |  |
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
   * **WAN / Outbound Interface (NIC1):** Dedicated to outbound cloud tunnel communication. Configured with a static address pointing to the edge gateway.
   * **LAN Interface (NIC2):** Dedicated to internal application traffic. Configured with a static address on the application subnet with **no default gateway** (`0.0.0.0`) to prevent asymmetric routing, pointing directly to internal Domain Controller DNS.

---

## 🎯 3. Private Application Target Definitions

Internal workloads were registered as **FQDN Targets** under `Group-1` inside Strata Cloud Manager:

| Application Name | FQDN Target | Protocol | Service Target | Application Status |
| :--- | :--- | :---: | :--- | :---: |
| **GLPI Helpdesk** | `glpi.lab.local` | TCP | Helpdesk Web Workload | ✅ Up |
| **Zabbix Monitoring** | `zabbix.lab.local` | TCP | Infrastructure Monitoring Server | ✅ Up |

User access requests to these FQDNs are intercepted by the GlobalProtect Agent or Secure Agentless Access portal and routed securely through the ZTNA tunnel.

---

## 🛡️ 4. Identity-Aware Security Rules

Security policies were configured under the **Mobile Users Container – Pre Rules** section in SCM to enforce role-based access:

| Rule Name | Action | Source User / Group | Destination Target | Application / Ports | Description |
| :--- | :---: | :--- | :--- | :--- | :--- |
| `Allow-HR-Zabbix` | **Allow** | `cn=hr-users` | `Zabbix-Target` | `web-browsing`, `ssl` | HR department access to monitoring dashboard. |
| `Allow-IT-GLPI` | **Allow** | `cn=it-admins` | `GLPI-Target` | `web-browsing`, `ssl` | IT Admin access to ticketing & asset management. |
| `Allow-Directors` | **Allow** | `cn=directors` | `GLPI-Target`, `Zabbix-Target` | `web-browsing`, `ssl` | Executive full access to internal web applications. |
| `Deny-All-Internal`| **Deny** | `Any` | `Internal-Subnets-Group` | `Any` | Implicit explicit drop for unauthorized internal traffic. |
