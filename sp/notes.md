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

### SQL Injections (06/10/2017)
- Attacker modifies SQL queries through uncleaned inputs

#### Potential damage
- **Confidentiality:** could read sensitive data
- **Integrity:** could change data
- **Authentication:** could bypass authentication
- **Authorisation:** could change authorisation info

#### Prevention mechanisms
- Prepared statements
  - Prepare phase:
    - Create SQL statement template with parameters
    - Send prepared statement to database for parse, compile, optimisation and storage
  - Binding phase:
    - Application binds values to parameters, executes statement
    - Can be done several times with different values
  - **Advantages:**
    - Reduced parsing time (only once for multiple executions)
    - Reduced bandwidth (only send params, not whole query)
    - Prevent injection by separating code and data
    - Critical code preimplemented by experts
- Object-relational mappers
  - Object database: DB management system, info is represented by objects
  - Convert info from relational to object database
  - **Advantages:**
    - Reduce code size
    - SQL injection can be blocked by the OR mapper
  - **Disadvantages:**
    - Hides implementation
- Stored procedures
  - Similar to parameterised queries
  - Difference to prepared statements: procedure stored in database
- Whitelist validation
  - Use when above methods are not an option
  - Defence in depth: always use, even on binded variables
- Escaping

#### Least privilege
- Users that only need read access to DB only get that
- Users only need access to part of DB only get that
- DB management systems not run as root
