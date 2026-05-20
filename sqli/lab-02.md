# Lab 02 — SQL Injection: Login Bypass

**Platform:** PortSwigger Web Security Academy  
**Difficulty:** Apprentice  
**Lab URL:** https://portswigger.net/web-security/sql-injection/lab-login-bypass

---

## Overview

| Field | Detail |
|---|---|
| **Vulnerability** | SQL Injection — Authentication bypass via comment injection |
| **CWE** | CWE-89: Improper Neutralization of Special Elements in an SQL Command |
| **CVSS v3.1 Score** | 9.8 — Critical |
| **CVSS Vector** | `AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H` |
| **ISO 27001 Controls** | A.8.28 — Secure Coding / A.5.17 — Authentication Information |
| **OWASP Top 10** | A03:2021 — Injection / A07:2021 — Identification & Authentication Failures |

---

## Vulnerability Description

The application embeds login credentials directly into a SQL query via string concatenation. By injecting a comment sequence (`--`) into the username field, an attacker can truncate the query and bypass the password check entirely — gaining access to any account without knowing the password.

**Vulnerable query (approximate):**
```sql
SELECT * FROM users WHERE username = 'administrator' AND password = 'wrongpassword'
```

After injection:
```sql
SELECT * FROM users WHERE username = 'administrator'--' AND password = 'wrongpassword'
```

The `--` comments out the password check. The query returns the administrator user and the login succeeds.

---

## Steps to Reproduce

1. Navigate to the login page and open Burp Suite to intercept requests.

2. Enter the following in the **username** field (any value in password):

   | Field | Value |
   |---|---|
   | Username | `administrator'--` |
   | Password | `anything` |

3. The resulting query becomes:
   ```sql
   SELECT * FROM users WHERE username = 'administrator'--' AND password = 'anything'
   ```

4. Password check is commented out → logged in as `administrator`.

See [`payloads/payloads.sql`](./payloads/payloads.sql) for all tested payloads.

---

## Impact

An unauthenticated remote attacker can log in as **any user** — including administrators — without credentials. This is a complete authentication bypass.

| CIA | Impact | Reason |
|-----|--------|--------|
| Confidentiality | **High** | Full access to all user data |
| Integrity | **High** | Attacker can modify data as admin |
| Availability | **High** | Attacker can delete or disrupt data |

> **Why is this CVSS 9.8 vs Lab 01's 7.5?**  
> Lab 01 was read-only data exposure. Here, the attacker gains full administrative control — all three CIA pillars are compromised, pushing the score to Critical.

---

## Root Cause

Authentication queries are built via string concatenation. There is no parameterization, no input validation, and no handling of SQL special characters.

See [`remediation/vulnerable.py`](./remediation/vulnerable.py) for the vulnerable pattern.

---

## Remediation

Use parameterized queries and proper password hashing — see examples:

- [`remediation/fix.py`](./remediation/fix.py) — Python (psycopg2 + bcrypt)
- [`remediation/fix.java`](./remediation/fix.java) — Java (JDBC + BCrypt)

### Additional Hardening

- **Hash passwords** with bcrypt, Argon2, or PBKDF2 — never store or compare plaintext
- Implement **account lockout** after N failed login attempts
- Add **MFA** for privileged accounts
- Log and alert on suspicious input patterns (e.g. `--`, `'`, `OR 1=1`)
- Apply WAF rules on authentication endpoints

---

## Comparison with Lab 01

| | Lab 01 — Hidden Data | Lab 02 — Login Bypass |
|---|---|---|
| **Entry point** | URL query parameter | Login form field |
| **Technique** | WHERE clause manipulation | Comment injection (`--`) |
| **Auth required** | No | No |
| **CVSS Score** | 7.5 High | 9.8 Critical |
| **Impact** | Read hidden records | Full account takeover |

---

## References

- [PortSwigger: SQL Injection Auth Bypass](https://portswigger.net/web-security/sql-injection/lab-login-bypass)
- [OWASP: Testing for SQL Injection (WSTG-INPV-05)](https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/07-Input_Validation_Testing/05-Testing_for_SQL_Injection)
- [CWE-89](https://cwe.mitre.org/data/definitions/89.html)
- [ISO/IEC 27001:2022 Annex A.5.17](https://www.iso.org/standard/27001)

---

*Writeup produced for educational purposes as part of PortSwigger Web Security Academy lab practice.*
