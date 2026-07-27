# S4 Test Result — Step-Up MFA Policy Enforcement

**Date Executed**: 2026-07-22  
**Platform**: Palo Alto Strata Cloud Manager (SCM) / Prisma Access  
**Identity Provider**: Microsoft Entra ID  

---

## 1. Policy & Trigger Configuration

### SCM Authentication Policy Rule
* **Rule Name**: `Enforce-StepUp-Sensitive-Apps`
* **Source Zone / User**: `Mobile Users` / `cn=it-admins`
* **Destination**: `10.240.X.X:80` (Sensitive App Gateway)
* **Authentication Profile**: `Entra-ID-StepUp-AuthProfile`

---

## 2. Test Execution Scenarios

### Test Case 1: Standard App Access (Baseline Connection)
* **Action**: User `user.itadmin@lab.internal` connects to GlobalProtect with primary MFA and accesses a standard internal web resource (`10.240.X.Y`).
* **Observed Result**: **PASS** — Access granted immediately without additional authentication prompts using the existing SAML session.

### Test Case 2: Sensitive App Access (Step-Up Triggered)
* **Action**: User attempts to navigate to the high-security admin portal (`10.240.X.X`).
* **Execution Sequence**:
  1. Traffic matched rule `Enforce-StepUp-Sensitive-Apps`.
  2. SCM redirected the system browser to the Entra ID SAML authentication endpoint.
  3. Entra ID evaluated Conditional Access sign-in frequency / auth strength policy and presented a secondary MFA challenge (Passkey/FIDO2 or Authenticator Push).
  4. User satisfied the prompt.
* **Observed Result**: **PASS** — Session token updated; access to `10.240.X.X` granted.

---

## 3. Telemetry & Verification Logs

```text
Time Generated: 2026-07-22 17:15:02 EEST
Source User: user.itadmin@lab.internal
Source IP: 100.64.X.X
Destination IP: 10.240.X.X:80
Auth Event: Authentication Step-Up Challenge Initiated
Rule Matched: Enforce-StepUp-Sensitive-Apps
Auth Profile: Entra-ID-StepUp-AuthProfile
Status: SUCCESS (MFA Satisfied at IdP)
