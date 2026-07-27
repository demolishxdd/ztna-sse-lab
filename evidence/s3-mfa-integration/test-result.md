# S3 Test Result — Microsoft Entra ID MFA & Conditional Access Validation

**Date Executed**: 2026-07-22[cite: 1]  
**Platform**: Palo Alto Prisma Access / GlobalProtect Client[cite: 1]  
**Identity Provider**: Microsoft Entra ID[cite: 1]  

---

## 1. Test Scenarios Execution Overview

| Test Case | Scenario Objective | Enforced Factor / Policy | Result | Verification Endpoint |
|---|---|---|---|---|
| **Test Case 1** | SAML Federation & Initial Handshake | SP-Initiated Redirect to Entra ID | **PASS** | `login.microsoftonline.com`[cite: 1] |
| **Test Case 2** | MFA Factor 1 Validation | MS Authenticator Push (Number Match) | **PASS** | Mobile App Prompt Satisfied[cite: 1] |
| **Test Case 3** | MFA Factor 2 Validation | FIDO2 Security Key / Passkey | **PASS** | Windows Security PIN / Token[cite: 1] |
| **Test Case 4** | Entra Conditional Access Audit | Enforce Intune Compliance & MFA | **PASS** | Entra ID Sign-in Audit Log[cite: 1] |

---

## 2. Execution Log & Verification Details

### Test Case 1: Federation & Initial Login
* **Objective**: Confirm GlobalProtect correctly hands off primary authentication to Microsoft Entra ID[cite: 1].
* **Execution**: User initiated connection via GlobalProtect[cite: 1]. The system browser opened and redirected to `login.microsoftonline.com`[cite: 1].
* **Observed Result**: User entered corporate UPN (`user.director@lab.internal`) and was challenged by Entra ID[cite: 1].

---

### Test Case 2: MFA Factor 1 — Microsoft Authenticator Push (Number Matching)
* **Objective**: Verify that login requires out-of-band push authorization[cite: 1].
* **Execution Sequence**:
	1. User supplied primary credentials[cite: 1].
	2. Entra ID rendered a 2-digit number matching challenge (`92`) in the browser[cite: 1].
	3. User submitted matching digits into the mobile Microsoft Authenticator application[cite: 1].
* **Observed Result**: Browser held execution until push approval completed, issuing a valid SAML assertion and transitioning GlobalProtect to **Connected**[cite: 1].

---

### Test Case 3: MFA Factor 2 — FIDO2 Security Key / Passkey
* **Objective**: Validate support for phishing-resistant hardware authenticators[cite: 1].
* **Execution Sequence**:
	1. User selected "Sign in with a passkey or security key"[cite: 1].
	2. OS prompted for Windows Security PIN / FIDO2 touch verification[cite: 1].
* **Observed Result**: Cryptographic token assertion was validated by Entra ID, allowing GlobalProtect to establish the tunnel[cite: 1].

---

### Test Case 4: Entra ID Conditional Access Policy Audit Log

Below is the sanitized audit record extracted from the Microsoft Entra Admin Center Sign-in Logs (`Activity Details: Sign-ins`)[cite: 1]:

```text
User: user.director@lab.internal
Application: Palo Alto Networks - GlobalProtect
Client App: Browser
Location / Network: Reduta, BG (194.34.X.X)
Device ID: REDACTED_DEVICE_GUID
Device Platform: Windows 10

Conditional Access Policy Evaluation Summary:
-------------------------------------------------------------------------------------
Policy Name                         | Grant Controls              | Result
-------------------------------------------------------------------------------------
Multifactor authentication for GP  | Require multifactor auth    | Success
Prisma Access - Enforce Compliance | Require compliant device    | Success
Step-Up-MFA-Authentication-Test     | Sign-in frequency           | Not Applied
-------------------------------------------------------------------------------------
