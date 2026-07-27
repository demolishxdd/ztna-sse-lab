# 02 — Microsoft Entra ID Integration & SAML 2.0 Federation

## 📋 Overview
This document details the configuration of **Microsoft Entra ID** as the primary Cloud Identity Provider (IdP) for the Palo Alto Prisma Access ZTNA/SSE environment[cite: 1]. The integration establishes a hybrid identity flow using SAML 2.0 authentication, Cloud Identity Engine (CIE) directory synchronization, and Microsoft Intune Conditional Access posture policies[cite: 1].

---

## 🔄 1. Directory Synchronization (Cloud Identity Engine)

To enable identity-aware security policies inside Strata Cloud Manager (SCM), Palo Alto **Cloud Identity Engine (CIE)** was integrated with Microsoft Entra ID[cite: 1]. This allows Prisma Access to evaluate user identity and group memberships directly in access policies without exposing password hashes[cite: 1].

### Onboarding & Sync Workflow
1. **Directory Setup:** Logged into the Palo Alto Hub and created a new directory instance within the Cloud Identity Engine application, selecting Microsoft Entra ID as the directory type[cite: 1].
2. **Tenant Authorization:** Retrieved the Directory / Tenant ID (`00000000-0000-0000-0000-000000000000`) from the Microsoft Entra Admin Center and generated an administrative consent onboarding URL[cite: 1].
3. **Enterprise Application Consent:** Authenticated using a Global Administrator account to grant required directory read permissions (`Directory.Read.All`) for the Palo Alto Cloud Identity Engine enterprise application[cite: 1].
4. **Profile Binding:** Linked the synchronized Cloud Identity Engine profile to Prisma Access to enable user and group attribute evaluation across security policies[cite: 1].

---

## 🔐 2. SAML 2.0 Single Sign-On (SSO) Setup

SAML 2.0 authentication was configured to delegate user authentication from GlobalProtect / Prisma Access to Microsoft Entra ID[cite: 1].

### Enterprise Application Configuration
1. **App Registration:** Registered a new Enterprise Application (`Palo Alto Networks - GlobalProtect`) in the Microsoft Entra Admin Center[cite: 1].
2. **Basic SAML Settings:** Configured Service Provider (SP) parameters to direct authentication flows[cite: 1]:
   * **Identifier (Entity ID):** `https://gp-gateway.lab.net:443/SAML20/SP`[cite: 1]
   * **Reply URL (ACS URL):** `https://gp-gateway.lab.net:443/SAML20/SP/ACS`[cite: 1]
   * **Sign-on URL:** `https://gp-gateway.lab.net`[cite: 1]
3. **Attribute Mapping:** Mapped the SAML User Identifier claim (`http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name`) to the user's UserPrincipalName (UPN)[cite: 1].

---

## ⚙️ 3. Strata Cloud Manager SAML Profile & Binding

1. **Metadata Import:** Downloaded the signed **App Federation Metadata XML** file from Microsoft Entra ID and imported it into Strata Cloud Manager under `Identity Services` $\rightarrow$ `Authentication` $\rightarrow$ `Server Profiles` $\rightarrow$ `SAML Profiles`[cite: 1].
2. **Clock Skew:** Set a maximum clock skew value of `60 seconds` to accommodate potential time drift between the IdP and SP[cite: 1].
3. **Authentication Profile Creation:** Authored a SAML authentication profile (`Entra-ID-SAML-Auth`) pointing to the imported Entra ID server profile[cite: 1].
4. **Agent Binding:** Under the `Access Agent` scope, assigned `Entra-ID-SAML-Auth` as the primary user authentication method and moved it to the top of the processing list[cite: 1].

---

## 🛡️ 4. Conditional Access & Intune Compliance Enforcement

To enforce Zero Trust posture validation, a Conditional Access policy was configured in Microsoft Entra ID[cite: 1].

### Policy Rules & Settings
* **Policy Name:** `Prisma Access - Enforce Intune Compliance`[cite: 1]
* **Assignments:** Assigned to ZTNA Mobile User groups targeting the `Palo Alto Networks - GlobalProtect` Enterprise Application[cite: 1].
* **Grant Controls:** Configured to `Require device to be marked as compliant` (verified by Microsoft Intune)[cite: 1].
* **Browser Redirection:** Enabled `Use Default Browser for SAML Authentication` in the GlobalProtect App Configuration to allow the agent to launch the system browser (Edge/Chrome) during SAML logins, ensuring native evaluation of platform SSO tokens and Intune device certificates[cite: 1].

### Verification Flow
1. User opens GlobalProtect / Prisma Access Agent and initiates a connection[cite: 1].
2. Request redirects to Microsoft Entra ID SAML authentication via the default browser[cite: 1].
3. Entra ID evaluates the device object state in Intune against the Conditional Access policy[cite: 1].
4. Access is granted if the endpoint is compliant; access is blocked if the device is unmanaged or non-compliant[cite: 1].
