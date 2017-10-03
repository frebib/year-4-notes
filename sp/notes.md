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

## Code Injection (03/10/2017)
### Handling external inputs
#### Validate inputs
- Badly formed inputs may lead to
  - Crash
  - Unexpected behaviour
  - Resource exhaustion
  - Security issues
- Cope with badly formed input
  - Identify all inputs and sources
  - Check inputs are formed properly

#### What is input
- User-entered data
- Program arguments
- File contents
- File handles
  - stdin, stdout, stderr
- Working directory
- Environment variables, config, registry values, umask values, etc.

#### Web inputs
- URL
  - http://www.example.com/index.php/foo/bar/test.html
- Encoded URL
  - Standard hex encoding
  - Different UTF-8 bytestreams decodes to same value
- HTTP request body
- HTTP headers
  - Cookies
  - Referrer

#### Input validation
- Validate all inputs
  - Strong typing, length checks, range checks
  - Syntax
- Validate inputs from all sources
- Good practice
  - Easy to verify inputs are validated
  - Establish trust boundaries
  - Validate at each module border
  - Store trusted and untrusted data separately

#### Whitelists / Blacklists
- Whitelist defines what is allowed, rejects anything else
- Blacklist defines what is not allowed, allows anything else
- Whitelists preferred, easy to forget cases in blacklists

#### Whitelist validation
- Number ranges
- Input lengths
- Enumeration of multiple choices
- Regular expressions

#### Escape sequences
- Languages have characters with special meaning
- Need to distinguish between character itself and special meaning
- Escape sequences are used to represent a character itself
- Example \. for "."

#### Parameterised interfaces
- Interface limits range of inputs allowed
- More chance to be correct
- Examples:
  - Prepared statements in MySQL
  - Object-relational mappers

#### Am I vulnerable?
- Wherever an interpreter is used, separate untrusted data and the command/query
- Prevent known attack patterns
- Use automated tools
  - Static analysis: search known vulns in code
  - Dynamic analysis: run code with known attack patterns
