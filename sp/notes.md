# Secure Programming

## Introduction (26/09/2017)
### Why programmers write insecure code
- No customer demand for security
  - Secure code requires time and money
  - Security measures may affect usability
  - Users don't care about security
- Lack of security awareness and knowledge. Need to...
  - Understand the threat model
  - Know at least main security bugs
  - Use existing tools to help you
  - Keep updated at relevant places
- Writing Secure code is hard
- Laziness

### What is secure?
- **Confidentiality:** protect data from unauthorised reading
- **Integrity:** protect data from tampering
- **Availability:** data must be available to legitimate users
- **Authentication:** check identity of users/processes

## General principles (29/09/2017)
- Get code right
  - Not vulnerable to integer overflow
- Check inputs
  - Not vulnerable to SQL injection
- Least privilege and deny by default
  - Give least privilege needed to work
  - Isolate code modules with higher privileges
  - Whitelisting safer than blacklisting
- Secure-friendly architecture
  - Simple code easier to review, update, etc.
- Defense in depth
  - Multiple layers of security
  - Block malicious inputs, but still assume some may get through
- Stay up-to-date


- OWASP: Open Web Application Security Project
- CWE: Common Weakness Enumeration

### Common Criteria (CC)
- Standard for computer security certification
- Provides assurance to buyers of a security product

### Proper tools
- OS security features
- Secure libraries
- Cryptography
- Static analysis
  - Looking at code for patterns showing vulnerabilities
- Dynamic analysis
- OWASP tools
