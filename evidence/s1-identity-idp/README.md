# S1 — Identity & IdP Integration (Entra ID & CIE)

## 1. Scope & Architecture
This directory documents the SAML 2.0 federation and directory synchronization between Palo Alto Strata Cloud Manager (SCM) / Prisma Access and Microsoft Entra ID[cite: 1]. 

- **Identity Provider (IdP)**: Microsoft Entra ID (Cloud Identity Provider)[cite: 1]
- **Directory Sync**: Palo Alto Cloud Identity Engine (CIE) Enterprise App[cite: 1]
- **Authentication Flow**: Service Provider (SP)-Initiated SAML 2.0 via System Default Browser[cite: 1]
- **Attribute Mapping**:
  - `Username Attribute`: `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name`[cite: 1]
  - `Group Mapping`: Mapped via CIE sync rules (e.g., `cn=it-admins`, `cn=hr-users`, `cn=directors`)[cite: 1]

## 2. Evidence Files
| File | Description |
|---|---|
| `test-result.md` | Complete verification logs, SAML endpoints, and Entra ID integration steps |
| `sanitized-artifacts/cie-entra-sync.png` | CIE status verifying successful synchronization with Entra ID |
| `sanitized-artifacts/saml-gp-app-config.png` | Basic SAML configuration inside Microsoft Entra Admin Center |

## 3. Sanitization Matrix
- Real Tenant / Directory IDs $\rightarrow$ `REDACTED_TENANT_ID` / `3c5c89ee-XXXX-XXXX-XXXX-XXXXXXXXXXXX`
- User UPNs $\rightarrow$ `LeeG@m365xREDACTED.onmicrosoft.com`, `teodor.zhelyazkov@m365xREDACTED.onmicrosoft.com`[cite: 1]
- Public / Client WAN IPs $\rightarrow$ `194.34.X.X`, `176.222.X.X`[cite: 1]
- Private Infrastructure IPs $\rightarrow$ Maintained standard RFC 1918 range (`192.168.50.X`, `10.240.240.X`)[cite: 1]
