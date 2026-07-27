# 01 — Lab Topology & Infrastructure Architecture

## 📋 Overview
This document outlines the baseline hardware, virtualization, and network architecture built for the Zero Trust Network Access (ZTNA) and Security Service Edge (SSE) implementation lab. The architecture mirrors an enterprise on-premises datacenter integrated with cloud-delivered security services[cite: 1].

---

## 🔌 1. Physical Topology & Hardware Stack

The physical infrastructure consists of enterprise-grade networking and server hardware[cite: 1]:

| Device Type | Hostname / Role | Model / Platform | Notes / Interface Role |
| :--- | :--- | :--- | :--- |
| **Perimeter Firewall** | `FW-01` | FortiGate 500E | WAN Edge / ISP Router Gateway[cite: 1] |
| **Core Router** | `R1` | Cisco 2911 Router | Inter-VLAN Routing & Gateway Transit[cite: 1] |
| **Managed Switch** | `SW1` | Cisco Catalyst 3560-CG | Access & Trunk Switch Port Aggregation[cite: 1] |
| **Hypervisor Host** | `SRV1` | Dell PowerEdge R440 | Bare-metal VMware ESXi Virtualization Host[cite: 1] |
| **Wireless AP** | `AP1` | Cisco AIR-SAP1602-E-K9 | Wireless Management Segment Access[cite: 1] |

---

## 🌐 2. Network Segmentation & Addressing Plan

The environment is logically partitioned into isolated VLANs to enforce strict network-level segmentation prior to ZTNA policy enforcement[cite: 1]:

### VLAN & Subnet Allocation
| VLAN ID | Subnet Name | Network Subnet | Subnet Mask | Default Gateway | Segment Purpose |
| :---: | :--- | :--- | :--- | :--- | :--- |
| **10** | `USERS` | `192.168.10.0/24` | `255.255.255.0` | `192.168.10.1` | Local user test endpoints & clients[cite: 1] |
| **40** | `MGMT` | `192.168.40.0/24` | `255.255.255.0` | `192.168.40.1` | Out-of-band network management & APs[cite: 1] |
| **50** | `SERVER` | `192.168.50.0/24` | `255.255.255.0` | `192.168.50.1` | Protected application servers & ZTNA Connector[cite: 1] |

---

## 🖥️ 3. Virtualization & Service Architecture (ESXi Host)

The Dell PowerEdge server runs **VMware ESXi** to host core infrastructure workloads and protected private applications[cite: 1]:
