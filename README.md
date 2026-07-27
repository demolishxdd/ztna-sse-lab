# Enterprise ZTNA & SSE Implementation Lab

## 📌 Executive Overview
Architected, deployed, and validated an enterprise-grade **Zero Trust Network Access (ZTNA 2.0)** and **Security Service Edge (SSE)** solution using **Palo Alto Prisma Access (Strata Cloud Manager)**, **Microsoft Entra ID**, **Microsoft Intune**, and **VMware ESXi**.

The primary objective of this project was to transition from legacy perimeter-based VPN access to a continuous-verification Zero Trust framework. The environment enforces least-privilege access, identity-aware policies, device compliance posture, inline threat inspection (SWG/CASB), and declarative Policy as Code (PaC) via Terraform.

---

## 🏗️ Architecture & Component Topology
* **Cloud Security Platform:** Palo Alto Prisma Access, Strata Cloud Manager (SCM), GlobalProtect Agent, Prisma Access Browser
* **Identity & Access Management (IdP):** Microsoft Entra ID (SAML 2.0 Federation, MFA, Conditional Access)
* **Endpoint Management & Compliance:** Microsoft Intune (BitLocker, EDR compliance posture checks)
* **Protected Internal Services:** GLPI (IT Service Desk & Asset Management), Zabbix (Infrastructure Monitoring), Active Directory DS, RDP, SSH, SMB Shares
* **Virtualization & Hardware Infrastructure:** VMware ESXi, Cisco 2911 Routers, Cisco Catalyst Switches, FortiGate NGFW
* **Infrastructure as Code (IaC):** Terraform (`PaloAltoNetworks/scm` provider)

---

## 🎯 Verification Scorecard (S1 – S10)

| ID | Testing Category | Validation Details & Test Outcomes | Status |
| :--- | :--- | :--- | :---: |
| **S1** | **Outbound-Only Connectivity** | Perimeter firewall inbound ACLs locked (0 open inbound ports); ZTNA Connector established secure outbound-only TLS 443 tunnels. | ✅ Pass |
| **S2** | **Granular Access Control** | Least-privilege transport and port scoping verified across Web (GLPI/Zabbix), SSH, RDP, SMB, and arbitrary TCP (10050). | ✅ Pass |
| **SAA**| **Secure Agentless Access** | Evaluated clientless HTML5 web portal rendering for isolated browser-based Web, SSH, and RDP sessions. | ✅ Pass |
| **S3** | **Identity & MFA Integration** | Federated SAML 2.0 login with Microsoft Entra ID, enforcing Authenticator Push (Number Matching) and FIDO2 Passkeys. | ✅ Pass |
| **S4** | **Mid-Session Step-Up MFA** | Dynamic re-authentication forced via Entra ID when accessing sensitive paths (e.g., `/front/logs.php`). | ✅ Pass |
| **S5** | **Device Posture & Compliance**| Integrated Intune compliance policies; non-compliant endpoints (missing BitLocker/EDR) blocked at login and session renewal. | ✅ Pass |
| **S6** | **High Availability & Scale** | Validated multi-connector Connector Group failover and horizontal scaling topology limits (up to 400k sessions). | ✅ Pass |
| **S7** | **Inline SSE (SWG & CASB)** | Verified SSL Forward Proxy decryption, custom URL filtering, EICAR malware blocking, DLP data pattern blocks, and Shadow IT discovery. | ✅ Pass |
| **S8** | **Centralized Audit Logging** | Exported cloud security telemetry and traffic logs to on-premise SIEM for continuous auditing. | ✅ Pass |
| **S9** | **Policy as Code (PaC)** | Declaratively provisioned security rules to Strata Cloud Manager using Terraform and reverse-generated HCL from live state. | ✅ Pass |
| **S10**| **Active Session Revocation** | Demonstrated sub-second clientless disconnects and network-level session drops upon administrator force-logout. | ✅ Pass |

---

## 📂 Repository Structure & Documentation Walkthrough
Detailed technical documentation and sanitized step-by-step guides are organized under the [`/docs`](./docs) folder:
* 📘 [**Topology & Infrastructure Setup**](./docs/01-topology-and-infrastructure.md)
* 🔐 [**Entra ID SAML Federation & Conditional Access**](./docs/02-entra-id-and-saml-federation.md)
* 🌐 [**Prisma Access & ZTNA Connector Deployment**](./docs/03-ztna-connector-deployment.md)
* 🧪 [**Comprehensive Testing & Verification Log (S1-S10)**](./docs/04-testing-and-verification.md)
* ⚙️ [**Terraform Policy as Code Configurations**](./terraform/)
