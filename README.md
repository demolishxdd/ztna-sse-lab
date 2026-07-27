# Enterprise ZTNA & SSE Implementation Lab

## 📌 Overview
Architected, deployed, and validated an enterprise **Zero Trust Network Access (ZTNA)** and **Security Service Edge (SSE)** solution using **Palo Alto Prisma Access (Strata Cloud Manager)**, **Microsoft Entra ID**, and **VMware ESXi**. 

The goal of this project was to enforce least-privilege, identity-aware access, eliminate inbound public attack surfaces, and implement real-time threat inspection and policy enforcement across core internal applications including **GLPI** and **Zabbix**.

---

## 🛠️ Tech Stack & Architecture
* **Security & SSE:** Palo Alto Prisma Access, Strata Cloud Manager, GlobalProtect, Prisma Access Browser
* **Identity & Access Management:** Microsoft Entra ID (SSO, MFA, Conditional Access)
* **Protected Internal Applications:** GLPI (IT Service Desk & Asset Management), Zabbix (Infrastructure Monitoring)
* **Infrastructure & Virtualization:** VMware ESXi, Ubuntu, Active Directory DS
* **SIEM & Logging:** Graylog, Syslog Forwarding

---

## 🎯 Key Capabilities & Test Scorecard

| Criterion | Configuration Details & Testing Results | Status |
| :--- | :--- | :---: |
| **S1 — Outbound-Only Access** | Enforced access via outbound 443 TCP connectors with 0 open inbound ports. | ✅ Pass |
| **S2 — Granular Access Control** | Per-user and per-app policy enforcement across Web (GLPI, Zabbix), SSH, RDP, SMB, and custom TCP ports. | ✅ Pass |
| **S3 — Identity & MFA Integration** | Federated with Microsoft Entra ID for SSO and enforced MFA upon login for internal apps (GLPI / Zabbix). | ✅ Pass |
| **S4 — Step-Up MFA** | Configured mid-session re-authentication for sensitive internal application access (e.g., Zabbix Admin Portal). | ✅ Pass |
| **S5 — Device Posture & Compliance**| Dynamically blocked non-compliant endpoints (missing EDR / disk encryption) from accessing GLPI & Zabbix. | ✅ Pass |
| **S6 — High Availability & Limits** | Deployed redundant connectors to test connector failover and connection limits. | ✅ Pass |
| **S7 — Inline Security (SWG/CASB)** | SSL Inspection, URL filtering, EICAR malware block, DLP, and Shadow IT discovery. | ✅ Pass |
| **S8 — Audit Logging** | Centralized audit logs exportable to on-premise Graylog SIEM. | ✅ Pass |
| **S9 — Policy as Code (PaC)** | Managed Strata Cloud Manager (SCM) security policies and access rules programmatically via Terraform. | ✅ Pass |
| **S10 — Session Control & Revocation**| Immediate session revocation upon risk-state change or policy break. | ✅ Pass |

---

## 🚀 Key Takeaways & Skills Demonstrated
1. **Zero Trust Architecture:** Applied Zero Trust principles to secure sensitive internal management services (GLPI, Zabbix) without relying on traditional inbound VPNs.
2. **Identity-Driven Security:** Tied network-level access directly to user identity, groups, and device posture.
3. **Log Integration:** Centralized SSE threat and traffic event logs into Graylog for continuous security monitoring.
