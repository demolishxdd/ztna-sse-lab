# 01 — Lab Topology & Infrastructure Architecture

## 📋 Overview
This document outlines the baseline hardware virtualization, logical network segmentation, and infrastructure architecture supporting the **Zero Trust Network Access (ZTNA 2.0)** and **Security Service Edge (SSE)** implementation lab. 

The architecture mirrors an enterprise on-premises datacenter hosting private applications and administrative services, integrated securely with cloud-delivered Prisma Access capabilities via inside-out, outbound-only encrypted connectivity.

---

## 🏗️ 1. Infrastructure & Virtualization Stack

The foundation of the environment consists of hypervisor virtualization, managed switching infrastructure, and cloud-managed edge transit.

| Component Role | Host / System Name | Platform / Model | Implementation Role |
| :--- | :--- | :--- | :--- |
| **Virtualization Host** | `SRV1` | VMware ESXi | Bare-metal hypervisor hosting internal applications, directory services, SIEM, and ZTNA connector virtual machines. |
| **Edge Router / Gateway** | `Edge-GW` | Edge Gateway Router | Handles upstream WAN transit and outbound internet connectivity for enterprise workloads. |
| **Managed Switching** | `SW1` | Managed L2/L3 Switch | Handles physical port aggregation, VLAN trunking, and localized layer-2 traffic switching. |
| **Identity Provider** | `Entra-ID` | Microsoft Entra ID | Cloud identity provider facilitating SAML 2.0 single sign-on, Conditional Access, and MFA. |
| **Cloud SSE Platform** | `SCM / Prisma` | Palo Alto Prisma Access | Cloud Security Processing Nodes (SPNs) managed via Strata Cloud Manager for policy enforcement and ZTNA routing. |

---

## 🌐 2. Network Segmentation & Functional Subnets

The environment is logically partitioned into functional, isolated network segments to enforce strict network-level control prior to ZTNA policy evaluation.

### Logical Subnet Allocation
| Subnet / Segment Name | Logical Role | Access Boundary | Segment Purpose |
| :--- | :--- | :--- | :--- |
| **User Endpoint Segment** | `User-VLAN` | Internal / LAN | Local corporate user workstations and testing endpoints. |
| **Management Segment** | `MGMT-VLAN` | Out-of-band | Dedicated management interfaces for ESXi hypervisor host and infrastructure appliances. |
| **Private Application Segment** | `App-VLAN` | Internal / Isolated | Hosted internal enterprise applications (GLPI, Zabbix) and Domain Controller/DNS. |
| **ZTNA Connector Transit Segment**| `WAN-Transit` | Outbound / Egress | Dedicated transit segment for ZTNA Connector NIC1 outbound cloud tunnel communication. |

---

## 🖥️ 3. Virtual Machine & Workload Mapping

All primary internal workloads run as virtual appliances on the VMware ESXi hypervisor host (`SRV1`), segmented by function across virtual port groups:

| Workload Name | Virtual Machine OS | Service / Application | Network Interface Allocation |
| :--- | :--- | :--- | :--- |
| **ZTNA Connector VM** | Custom Connector Appliance | Palo Alto ZTNA Connector | **Two-Arm Deployment:**<br>• NIC1: Outbound Transit Segment<br>• NIC2: Private Application Segment |
| **Active Directory / DNS** | Windows Server | Active Directory Domain Controller (`lab.local`) | Private Application Segment (Internal DC DNS) |
| **GLPI Helpdesk Server** | Ubuntu Linux / LAMP Stack | GLPI Asset Management & Ticketing | Private Application Segment |
| **Zabbix Monitoring Server**| Ubuntu Linux | Zabbix Enterprise Infrastructure Monitoring | Private Application Segment |
| **Graylog SIEM Collector** | Ubuntu Linux / Graylog | Centralized Audit & Syslog Logging Node | Private Application Segment |

---

## 🗺️ 4. Logical Architecture Diagram

```text
+---------------------------------------------------------------------------------------------------+
|                                 Palo Alto Prisma Access (Cloud SSE)                                |
|                                   [Strata Cloud Manager Control]                                  |
+---------------------------------------------------------------------------------------------------+
                                                  ^
                                                  | Encrypted Outbound Tunnels
                                                  | (TLS / IPsec Outbound-Only)
                                                  v
+---------------------------------------------------------------------------------------------------+
|                                     On-Premises Hypervisor Host                                   |
|                                         (VMware ESXi - SRV1)                                      |
|                                                                                                   |
|  +---------------------------------------------------------------------------------------------+  |
|  |                             ZTNA Connector Appliance (Two-Arm OVA)                          |  |
|  |  +--------------------------------------------+   +--------------------------------------+  |  |
|  |  | WAN / Outbound Interface (NIC1)            |   | LAN / Application Interface (NIC2)   |  |  |
|  |  | • Transit Segment (Edge Gateway)           |   | • App Segment (No Default Gateway)   |  |  |
|  |  | • Outbound Cloud Tunnel Initiator          |   | • Internal DNS (`lab.local` DC)      |  |  |
|  |  +--------------------------------------------+   +--------------------------------------+  |  |
|  +---------------------------------------------------------------------------------------------+  |
|                                                                   |                               |
|                                                                   v Internal App Routing          |
|  +---------------------------------------------------------------------------------------------+  |
|  |                                  Private Application Segment                                |  |
|  |                                                                                             |  |
|  |  +-----------------------+   +------------------------+   +------------------------------+  |  |
|  |  | Internal Domain       |   | GLPI Helpdesk          |   | Zabbix Monitoring            |  |  |
|  |  | Controller & DNS      |   | Application Server     |   | Server                       |  |  |
|  |  | (`dc.lab.local`)      |   | (`glpi.lab.local`)     |   | (`zabbix.lab.local`)         |  |  |
|  |  +-----------------------+   +------------------------+   +------------------------------+  |  |
|  |                                                                                             |  |
|  |  +---------------------------------------------------------------------------------------+  |  |
|  |  | Graylog SIEM Audit Logging Node                                                       |  |  |
|  |  +---------------------------------------------------------------------------------------+  |  |
|  +---------------------------------------------------------------------------------------------+  |
+---------------------------------------------------------------------------------------------------+
```

---

## 🛡️ 5. Zero Trust Network Perimeter & Isolation Controls

To support ZTNA 2.0 principles, the physical and virtual edge enforce strict architectural boundaries:

1. **Zero Inbound Open Ports:** The edge router and perimeter firewall enforce a strict default-deny policy for all inbound traffic originating from the public internet. No direct port forwarding or external NAT rules exist for internal resources.
2. **Inside-Out Connectivity:** The ZTNA Connector initiates outbound-only encrypted TLS/IPsec connections back to Prisma Access cloud processing nodes.
3. **Asymmetric Routing Avoidance:** The LAN interface (NIC2) of the two-arm ZTNA Connector contains no default gateway (`0.0.0.0`), preventing asymmetric routing and ensuring return traffic strictly flows back through the connector's active socket.
4. **Identity-Gated Application Exposure:** Private applications (`GLPI`, `Zabbix`) are never visible on the public Internet or local WAN, relying exclusively on identity verification via Entra ID prior to tunnel session authorization.
