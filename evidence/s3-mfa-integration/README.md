# S3 — Multi-Factor Authentication (MFA) & Conditional Access Integration

## 1. Scope & Architecture
This directory documents SAML 2.0 federation between Palo Alto Prisma Access / GlobalProtect and Microsoft Entra ID, enforcing Multi-Factor Authentication (MFA) and Conditional Access policies across multiple secondary authentication factors.

- **Identity Provider (IdP)**: Microsoft Entra ID
- **Authentication Handshake**: SAML 2.0 via System Default Browser
- **Enforced Factors Evaluated**:
  - **Factor 1 (Authenticator Push)**: Number-matching push notification via Microsoft Authenticator app[cite: 1].
  - **Factor 2 (FIDO2 / Passkey)**: Phishing-resistant FIDO2 hardware token / Windows Hello passkey[cite: 1].
- **Conditional Access Scope**: Enforces explicit Grant Controls requiring compliant device state and secondary factor satisfaction before issuing SAML assertions[cite: 1].

## 2. Evidence Files
| File | Description |
|---|---|
| `test-result.md` | Detailed test execution log across four MFA and Conditional Access scenarios |
| `sanitized-artifacts/entra-passkey-prompt.png` | Windows Security passkey/PIN entry prompt rendered during federated login |
| `sanitized-artifacts/authenticator-number-matching.png` | Microsoft Authenticator push notification displaying 2-digit number match |
| `sanitized-artifacts/globalprotect-connected.png` | GlobalProtect client transitioning to Connected state post-MFA validation |
| `sanitized-artifacts/entra-sign-in-audit-log.png` | Entra ID sign-in activity log confirming Conditional Access rule success |

## 3. Sanitization Matrix
- Identity UPNs $\rightarrow$ `user.director@lab.internal`
- Tenant Domain $\rightarrow$ `lab.internal`
- Egress Public WAN IP $\rightarrow$ `194.34.X.X`
- Client Tunnel / Source IP $\rightarrow$ `100.64.X.X`
- Device UUIDs $\rightarrow$ `REDACTED_DEVICE_GUID`
