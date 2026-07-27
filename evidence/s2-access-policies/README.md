# S2 — Access-Control Granularity & RBAC Policies

## 1. Scope & Architecture
This directory validates role-based access control (RBAC) and least-privilege security policy enforcement across private applications and administration protocols through Palo Alto Strata Cloud Manager (SCM) and Prisma Access ZTNA Connector.

- **Enforcement Layers**: SCM Mobile Users Pre-Rules & ZTNA Connector Transport Filtering
- **Target Applications & Protocols Tested**:
  - Web Portals: GLPI (`10.240.240.2:80`) & Zabbix (`10.240.240.3:80`)
  - Administration Protocols: SSH (`192.168.50.5:22`), RDP (`192.168.50.3:3389`), SMB (`192.168.50.3:445`), and TCP Agent (`192.168.50.5:10050`)
- **Roles Evaluated**:
  - `Director`: Full access to web portals, SSH, RDP, SMB, and TCP 10050.
  - `IT-Admin`: Access to GLPI web portal and SSH terminal only.
  - `HR / Staff (TBSA)`: Access to Zabbix web portal and TCP 10050 only.

## 2. Evidence Files
| File | Description |
|---|---|
| `test-result.md` | Complete verification execution matrix, CLI probe outputs, and traffic log analysis |
| `sanitized-artifacts/glpi-allow-access.png` | Successful web portal rendering for authorized role |
| `sanitized-artifacts/web-page-blocked.png` | Administrative block page delivered via URL profile on policy drop |
| `sanitized-artifacts/powershell-tnc-probe.png` | Network probe logs comparing Anycast FQDN transport vs direct IP connectivity |

## 3. Sanitization Matrix
- User Identity / UPNs $\rightarrow$ `user.director@lab.internal`, `user.itadmin@lab.internal`, `user.hr@lab.internal`
- Directory Domain $\rightarrow$ `lab.internal`
- Tunnel / Client IPs $\rightarrow$ `100.64.X.X`
- Public Internet Target IPs $\rightarrow$ `REDACTED_PUBLIC_IP`
- Private Anycast & Server IPs $\rightarrow$ RFC 1918 Lab Subnets (`10.240.240.X`, `192.168.50.X`)
