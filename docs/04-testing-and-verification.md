# 04 — Comprehensive Testing & Verification Log (S1 – S10)

## 📋 Overview
This document provides the complete empirical testing results and validation telemetry for the 10 core Zero Trust and SSE capabilities (S1–S10), including Secure Agentless Access (SAA).

---

## 🧪 Test Execution Matrix

### S1 — Outbound-Only Access (No Inbound Ports)
* **Objective:** Validate internal application access with perimeter firewall inbound ports fully locked.
* **Methodology:** Applied an `INTERNET-INBOUND` access control list (ACL) on the edge router explicitly denying and logging all inbound traffic directed to internal application subnets.
* **Result:** **PASSED ✅** — Remote users accessed GLPI and Zabbix through the ZTNA tunnel successfully. Inbound deny ACL match counters remained at **0**, while outbound TLS/IPsec session counters increased, proving 100% inside-out connectivity.

---

### S2 — Access Control Granularity (Multi-Protocol Scoping)
* **Objective:** Verify role-based, protocol-level access enforcement across Web, SSH, RDP, SMB, and TCP.

| Test Case | Role / User | Protocol & Target | Result | Observed Telemetry / Log Rule |
| :--- | :--- | :--- | :---: | :--- |
| **Web (GLPI)** | Executive (`secops-lead`) | HTTP/443 (`glpi.lab.local`) | **ALLOW ✅** | Portal loaded; matched `Allow-Directors`. |
| **Web (GLPI)** | TBSA (`test-user`) | HTTP/443 (`glpi.lab.local`) | **DENY ❌** | Admin Block Page rendered; matched `Deny-All-Internal`. |
| **SSH** | IT Admin (`sysadmin-01`) | SSH/22 (`Linux-App-Host`) | **ALLOW ✅** | Terminal session established; matched `S2-SSH`. |
| **SSH** | TBSA (`test-user`) | SSH/22 (`Linux-App-Host`) | **DENY ❌** | Connection reset (`reset-both`); matched `Deny-All-Internal`. |
| **RDP** | Executive (`secops-lead`) | RDP/3389 (`Domain-Controller`) | **ALLOW ✅** | Desktop rendered; logged on port 3389. |
| **SMB Share** | Executive (`secops-lead`) | SMB/445 (`\\Domain-Controller\Share`)| **ALLOW ✅** | Drive mounted; matched `S2-SMB` (`ms-ds-smbv3`). |
| **SMB Share** | IT Admin (`sysadmin-01`) | SMB/445 (`\\Domain-Controller\Share`)| **DENY ❌** | Windows Network Error; blocked by policy. |
| **TCP Port** | Executive (`secops-lead`) | TCP/10050 (`Zabbix-Agent-Host`) | **ALLOW ✅** | PowerShell `tnc` returned `TcpTestSucceeded: True`. |

---

### SAA — Secure Agentless Access Validation
* **Objective:** Test clientless HTML5 web portal rendering for Web, SSH, and RDP without installed agents.

| Role | Portal Visibility | Executed App | Protocol / Result |
| :--- | :--- | :--- | :---: |
| **Executive** | GLPI, Zabbix, Zabbix-SSH, AD-DC RDP | HTML5 RDP Session | **PASS ✅** — Rendered full desktop session in browser. |
| **IT-Admin** | GLPI, Zabbix-SSH | Web SSH Terminal | **PASS ✅** — Interactive web console established to Linux host. |
| **TBSA** | Zabbix (Only) | Zabbix Web Portal | **PASS ✅** — Restricted strictly to web portal; SSH/RDP hidden. |

> **Technical Boundary Note:** Secure Agentless Access (SAA) supports HTTP/HTTPS, HTML5 SSH, and HTML5 RDP. Raw socket protocols like SMB file sharing and arbitrary TCP listeners require the installed GlobalProtect Agent.

---

### S3 — Identity & Multi-Factor Authentication (Entra ID)
* **Objective:** Validate SAML 2.0 federation and multi-factor authentication factors.
* **Test Cases:**
  1. **Federation:** GlobalProtect successfully redirected login requests to `login.microsoftonline.com`.
  2. **Factor 1 (Authenticator Push):** Prompted 2-digit number matching; login held until approved on mobile device.
  3. **Factor 2 (FIDO2 Passkey):** Authenticated successfully using hardware token / Windows Hello PIN assertion.
  4. **Conditional Access Evaluation:** Verified Entra ID sign-in logs confirming `Require multifactor authentication` satisfied.

---

### S4 — Step-Up MFA on Established Session
* **Objective:** Force mid-session re-authentication when accessing protected sub-resources.
* **Execution:** User established a normal session on GLPI (`http://glpi.lab.local/index.php`). Upon attempting to open system administrative logs (`/front/logs.php`), Prisma Access Authentication Policy intercepted the request and redirected the browser to Entra ID for secondary MFA verification.
* **Result:** **PASSED ✅** — Path held blocked until MFA succeeded, logged in SCM as `cas-token-validated`.

---

### S5 — Device Posture & Compliance (Microsoft Intune)
* **Objective:** Gate network access based on endpoint posture state.
* **Test Cases:**
  * **Compliant Endpoint:** Intune-managed device with active BitLocker and EDR connected seamlessly.
  * **Non-Compliant Endpoint:** Attempted connection from an unmanaged device; Entra Conditional Access blocked login with message *"Device must comply with your organization's compliance requirements"*.
  * **Mid-Session Posture Break:** Unenrolled active device mid-session. Existing tunnel remained open until the next cookie renewal / re-auth timer, at which point session renewal was rejected and access revoked.

---

### S6 — Scale & Tunnel High Availability
* **Objective:** Verify multi-connector failover and capacity thresholds.
* **Architecture:** Deployed redundant ZTNA Connectors in `Group-1`. Validated active/active tunnel state to Prisma Access. Disabling the outbound network interface on Connector-01 resulted in seamless sub-second traffic failover to Connector-02 without dropping active web sessions.

---

### S7 — Inline SSE Inspection (SWG & CASB)
* **Objective:** Validate inline threat prevention, SSL decryption, DLP, and Shadow IT monitoring.

```
+-----------------------------------------------------------------------------------+
|                            Inline SSE Traffic Flow                                |
|                                                                                   |
|  +--------------+   Encrypted TLS   +-------------------+   Decrypted Payload   |
|  | Endpoint     | ----------------> | Prisma Access     | --------------------> |
|  | User Browser | <---------------- | SSL Forward Proxy | <-------------------- |
|  +--------------+   Custom CA Cert  +-------------------+   Inspected Content   |
|                                               |                                   |
|                                               +---> Advanced URL Filtering        |
|                                               +---> Antivirus / WildFire (EICAR)  |
|                                               +---> Enterprise DLP Patterns       |
|                                               +---> SaaS Security / CASB          |
+-----------------------------------------------------------------------------------+
```

* **SSL Forward Proxy Inspection:** Intercepted HTTPS traffic; browser verified certificate issuer replaced by custom root `ZTNA-LAB-Forward-Trust`.
* **URL Filtering:** Custom category `S7-Blocked-Test-Sites` blocked prohibited domains with an administrative block page.
* **EICAR Malware Block:** Download of `eicar.com.txt` over HTTPS was intercepted and blocked by WildFire Antivirus profile; Threat Log generated in SCM.
* **Data Loss Prevention (DLP):** Uploading sample files containing test sensitive patterns was blocked by Enterprise DLP engine.
* **CASB / Shadow IT:** SaaS Security Inline monitored SaaS application usage, reporting uploaded/downloaded byte volumes and application risk scores.

---

### S8 — Centralized Audit Logging
* **Objective:** Forward security logs to on-premises SIEM.
* **Execution:** Configured Syslog forwarding profile in SCM to export traffic, threat, and authentication events to an on-premises **Graylog SIEM** server for retention and operational visibility.

---

### S9 — Policy as Code (Terraform Integration)
* **Objective:** Manage SCM security rules declaratively via Terraform.
* **Execution:** Configured OAuth service account credentials (`client_id`, `client_secret`, `tsg_id`). Applied `glpi-policy.tf` creating `S9-Block-YouTube-Test` rule. Used `get_uuid.tf` and `import {}` blocks to reverse-generate HCL code from live console policies into `extracted_policy.tf`.

---

### S10 — Active Session Control & Revocation Immediacy
* **Objective:** Evaluate time required to terminate active user sessions.

| Revocation Method | Access Type | Trigger Action | Revocation Speed |
| :--- | :--- | :--- | :---: |
| **Admin Force Logout** | Secure Agentless Access (SAA) | Clicked *Disconnect* in SCM Active Connections | **< 1 Second** (Instant disconnect page) |
| **Admin Force Logout** | GlobalProtect Client Agent | Clicked *Force Logout* in SCM Connected Users | **~30 Seconds** (Tunnel teardown) |
| **Policy Change Push** | GlobalProtect Client Agent | Changed rule Allow $\rightarrow$ Deny & pushed config | **~5 Minutes** (Config commit & push cycle) |
