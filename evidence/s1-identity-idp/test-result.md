# S1 Test Result — Microsoft Entra ID & Cloud Identity Engine (CIE) Integration

**Date Executed**: 2026-07-22  
**Platform**: Palo Alto Strata Cloud Manager (SCM) / Prisma Access Access Agent  
**Identity Source**: Microsoft Entra ID (Hybrid AD Sync)  

---

## 1. SAML 2.0 Endpoint Configuration

### Identity Provider (Entra ID) Endpoints
* **Identifier (Entity ID)**: `https://lab-spov.gpcloudservice.com:443/SAML20/SP`
* **Reply URL (ACS)**: `https://lab-spov.gpcloudservice.com:443/SAML20/SP/ACS`
* **Sign-on URL**: `https://lab-spov.gpcloudservice.com`

### SCM Profile Binding
* **Server Profile**: `SAML_IDP_2026-06-30` (Imported via `Palo Alto Networks - GlobalProtect.xml` Federation Metadata)
* **Max Clock Skew**: `60 seconds`
* **Authentication Profile**: `Entra-ID-SAML-Auth`
* **Browser Mode**: `Use Default Browser for SAML Authentication` (Enabled under Agent App Configuration)

---

## 2. Directory Synchronization Verification (CIE)

Cloud Identity Engine (CIE) was integrated via the recommended Enterprise App flow to fetch group memberships for RBAC policy enforcement.

```text
[CIE Sync Log]
Status: Success
Display Name: Lab-Environment
Primary Domain Name: lab.internal
Directory Sync Status: Active
Users & Groups Ingested: 
  - cn=it-admins,ou=groups,dc=ztna,dc=local
  - cn=hr-users,ou=groups,dc=ztna,dc=local
  - cn=directors,ou=groups,dc=ztna,dc=local
