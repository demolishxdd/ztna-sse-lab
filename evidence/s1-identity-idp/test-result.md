# S1 Test Result — Microsoft Entra ID & Cloud Identity Engine (CIE) Integration

**Date Executed**: 2026-07-22[cite: 1]  
**Platform**: Palo Alto Strata Cloud Manager (SCM) / Prisma Access Access Agent[cite: 1]  
**Identity Source**: Microsoft Entra ID (Hybrid AD Sync)[cite: 1]  

---

## 1. SAML 2.0 Endpoint Configuration

### Identity Provider (Entra ID) Endpoints
* **Identifier (Entity ID)**: `https://tbs-spov.gpcloudservice.com:443/SAML20/SP`[cite: 1]
* **Reply URL (ACS)**: `https://tbs-spov.gpcloudservice.com:443/SAML20/SP/ACS`[cite: 1]
* **Sign-on URL**: `https://tbs-spov.gpcloudservice.com`[cite: 1]

### SCM Profile Binding
* **Server Profile**: `SAML_IDP_2026-06-30` (Imported via `Palo Alto Networks - GlobalProtect.xml` Federation Metadata)[cite: 1]
* **Max Clock Skew**: `60 seconds`[cite: 1]
* **Authentication Profile**: `Entra-ID-SAML-Auth`[cite: 1]
* **Browser Mode**: `Use Default Browser for SAML Authentication` (Enabled under Agent App Configuration)[cite: 1]

---

## 2. Directory Synchronization Verification (CIE)

Cloud Identity Engine (CIE) was integrated via the recommended Enterprise App flow to fetch group memberships for RBAC policy enforcement[cite: 1].

```text
[CIE Sync Log]
Status: Success
Display Name: Contoso
Primary Domain Name: m365xREDACTED.onmicrosoft.com
Directory Sync Status: Active
Users & Groups Ingested: 
  - cn=it-admins,ou=groups,dc=ztna,dc=local
  - cn=hr-users,ou=groups,dc=ztna,dc=local
  - cn=directors,ou=groups,dc=ztna,dc=local
```

---

## 3. Live User Authentication & Role Assertion Execution

During testing, authentication was validated against three distinct user profiles to ensure SAML tokens and identity claims bind correctly to GlobalProtect agent sessions[cite: 1]:

### Test Execution Table
| User UPN | Assigned Role | Primary Auth Method | IdP Result | SCM Profile Matched |
|---|---|---|---|---|
| `LeeG@m365xREDACTED.onmicrosoft.com` | Director | SAML + MFA (Passkey/Push) | SUCCESS | `Entra-ID-SAML-Auth` |
| `teodor.zhelyazkov@m365xREDACTED.onmicrosoft.com` | IT-Admin | SAML + MFA (Authenticator) | SUCCESS | `Entra-ID-SAML-Auth` |
| `MeganB@m365xREDACTED.onmicrosoft.com` | TBSA / HR | SAML + MFA (Authenticator) | SUCCESS | `Entra-ID-SAML-Auth` |

---

## 4. SAML Response Verification Log (Decoded & Sanitized)

Below is an excerpt from the SCM `Network/Authentication` log confirming successful token validation and claim extraction[cite: 1]:

```text
Time Generated: 2026-07-22 16:49:31 EEST
Source IP: 100.92.3.2
Authenticated User Domain: m365xREDACTED
Authenticated User Name: leeg
Auth Event: Authentication Success
Subtype: Cloud Authentication Service
Auth Server Profile: Entra-ID-SAML-Auth

Event Sequence:
16:49:17 | cas-client-redirect  | Redirecting user browser to login.microsoftonline.com
16:49:30 | cas-token-received   | SAML Assertion received from Entra ID
16:49:31 | cas-mfa-info         | MFA Claim satisfied at Identity Provider level
16:49:31 | cas-token-validated  | Signature verified against imported Entra ID Signing Cert
16:49:31 | Authentication Success| Session token generated for user: leeg
```

---

## 5. Summary & Verification Verdict
* **SAML Trust Established**: Yes (Federation Metadata successfully imported, clock skew set to 60s)[cite: 1]
* **System Browser Redirection**: Passed (GlobalProtect seamlessly launches Edge/Chrome for SSO)[cite: 1]
* **Group Claims Ingested**: Yes (CIE sync allows rules targeting `cn=it-admins`, `cn=directors`, etc., to enforce least-privilege access)[cite: 1]
