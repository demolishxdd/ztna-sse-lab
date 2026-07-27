# S4 — Step-Up Multi-Factor Authentication (MFA)

## 1. Scope & Architecture
This directory validates Step-Up Authentication policies configured within Palo Alto Strata Cloud Manager (SCM) and Microsoft Entra ID. Step-Up MFA enforces real-time re-authentication when users attempt to access sensitive internal applications or perform high-privilege administrative actions after establishing their base GlobalProtect connection.

- **Enforcement Trigger**: Access attempts to sensitive internal resources (e.g., administrative web portals or SSH endpoints)
- **Identity Provider (IdP)**: Microsoft Entra ID
- **Mechanism**: SCM Authentication Rules combined with Entra Conditional Access Authentication Strengths / Sign-in Frequency controls
- **Target Resources Evaluated**:
  - `Admin Portal`: Step-up required upon access request
  - `Standard Apps`: Initial connection MFA retained (no re-prompt required)

## 2. Evidence Files
| File | Description |
|---|---|
| `test-result.md` | Detailed execution log and policy evaluation steps for step-up challenges |
| `sanitized-artifacts/step-up-prompt.png` | Browser re-authentication prompt triggered on sensitive app access |
| `sanitized-artifacts/scm-auth-rule.png` | SCM Authentication Rule configuration matching target application traffic |

## 3. Sanitization Matrix
- User Identity / UPNs $\rightarrow$ `user.director@lab.internal`, `user.itadmin@lab.internal`
- Directory Domain $\rightarrow$ `lab.internal`
- Tunnel / Client IPs $\rightarrow$ `100.64.X.X`
- Target Resource Subnets $\rightarrow$ RFC 1918 Lab Subnets (`10.240.X.X`, `192.168.X.X`)
