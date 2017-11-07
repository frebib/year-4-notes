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

### Cross-site scripting attacks (XSS)
- Inject js code into the client's browser via messages between client/server


#### Impact
- Cookie or session data sent to attacker
- Browser history, documents revealed
- Redirected to dangerous website
- Trojan installed

#### DOM-based XSS
- DOM = Document Object Model
  - Representation of HTML doc
  - Separates doc structure from content
  - DOM includes document's URL
- Attacks are entirely client side
  - Use anchor tags '#' in HTTP request
  - Anchor tags not sent to the server
  - Full URL stored in the DOM
  - Script executed by browser when document is loaded

#### Preventing XSS
- Escape untrusted input and output data
- When needing to allow code, use sanitizing libraries on untrusted inputs
- Use Context Security Policy (CSP)

#### Set cookies HttpOnly
- Cookies often used to create HTTP sessions
- Cookies contain auth credentials
- HttpOnly cookie flag prevents js script access to it
- Mitigates impact of XSS attacks

#### Content security policy (CSP)
- Browser can only use resources from trusted sources
- Browser should ignore hostile sources
- Enabled in HTTP header

## Web Sessions (17/10/2017)

* Authentication: Verifying the user
* Authorisation: Verifying permission (of the user/action)

### Authentication Methods

* What you know
  - Passwords
* What you have
  - Physical key
  - Physical device
  - Certificate
* What you are
  - Biometrics

#### Password Authentication Methods

* Basic auth: Sending the password in the clear (e.g. HTTP basic auth)
* Digest auth: Sending hash of a password
* Challenge-Response:
  1. Client initiates a connection
  2. Server sends a challenge
  3. Client sends response
  4. Server checks/verifys response

Client’s response is a cryptographically strong function of challenge and password

* HTTPS (HTTP over TLS)
  - Agree a common secret session key (key exchange via DHE)
  - Communicate using encrypted session via agreed secret session key

### HTTP

* HTTP is stateless
  - Each request is independent to the previous
  - `keep-alive` or `persistent` connections can be used but will still timeout after several minutes

#### Sessions

* Aim: extend the length of communication
* Idea:
  - Client opens a connection
  - Server sends a session ID to identify the client
  - Client uses session id in every communication with the server to identify itself

##### Methods of sending Session ID

* URL parameters `example.com/page1?id=..`
* Body arguments on POST requests
* Cookies via header: `Cookie: ..`/`Set-Cookie: ..`
* [Proprietary](http://i.imgur.com/V5K7N1I.jpg) HTTP headers

### Security Threats

* Stealing cookies
  Impersonating a user by posing as them with their authentication
  - Session Hijacking: steal a session id and use it
    * Session fixation: give the user a session id to use
    * Packet sniffing: steal via packet observation
    * Malware/Spyware
    * XSS
  - Cross-Site Request Forgery: make the client perform an action whilst holding the session id, allowing it to be stolen.

#### Countermeasures

* Don't send session ids in plaintext
* Use unpredictable ids (cryptographically secure randoms)
* Use short-lived sessions
* Regenerate fresh ids at login
* Check source IP address against cookie (not always effective)
* Refresh ids regularly (regenerate)
* Ensuring the client remembers to log out

####  HTTP Cookie attributes

* `HTTPOnly` - cookie cannot be accessed by scripts (helps against XSS attacks) _(?)_
* `SameSite` - only allow cookie on the same domain
* `Domain` and `Path` - restrict cookie sending by domain and subpath
* `MaxAge` - timeout cookie after some time
* `Secure` - only allow cookies on HTTPS connections

### HTTPS (Secure HTTP)

* HTTP over TLS (SSL)
  - You know what TLS is, this isn't 'Intro to Security'

* Provides advantages:
  - Confidentiality (AES encrypted transport)
  - Authenticatiotn (client/server certificates)
  - Integrity (Signatures)
  - PFS (Forward secrecy): old messages cannot be retrieved with a current key/certificate

## Race Conditions (31/10/2017)
> Anomalous behaviour due to unexpected critical dependence on relative timing of events

### Secure file opening
- **open:** checks effective UID permissions
- **access:** checks real UID permissions

#### Example of TOCTOU vulnerable code
```c
if ( access (" filename ", W_OK ) != 0) {
  exit (1);
}
fd = open (" filename ", O_WRONLY );
write ( fd , buffer , sizeof ( buffer ));
```

Something unexpected may happen between access check and when file is used

#### Time Of Check to Time Of Use (TOCTOU)
- Race condition - something unexpected may happen between access check and when file is used
- May be able to replace file by another one after access check
- Use symlinks to redirect filenames to files
- Attacks require local access to system and precise timing

![](https://i.imgur.com/xshgb7R.png)

- Improve attack success probability
  - Slow down computer with CPU intensive programs
  - Run many attack processes in parallel

#### Countermeasures
- Use atomic operations
  - Check and use in single system call
  - Use `open ( "filename", O_CREAT | O_EXCL | O_WRONLY );
  - If `O_CREAT` and `O_EXCL` set, open fails if file exists
- Decrease probability (check-use-check again)
  - Get file info, open, get file info, abort if info are different
  - Attacker can defeat by restoring file
  - Increase number of checks to reduce success probability
- Drop perms
  - Use seteuid to temp drop real UID perms
- Use unpredictable filenames
  - Hard for attacker to attack filename he doesn't know
  - Filenames aren't totally unpredictable
  - Better to use mkstemp, which returns a file descriptor

### Locking bugs
#### Example: incrementing a global value
{Missing image}

- Needs synchronisation mechanism between threads (enforce atomicity)

### Locks
- When resource is in use, lock to prevent use
- BEWARE OF THE DEADLOCKS OMG
- Unix
  - Shared ("reading") and exclusive ("writing") locks
  - Can be ignored
- Windows
  - File system prevents write or delete access on executing files
  - Share-access controls for whole-file access-share for read, write delete
  - Byte-range locks

### Databases: Transactions (07/11/2017)
- Sequence of operations, perceived as single logical operation on data
- Must have ACID properties
  - Atomicity - all or nothing
  - Consistency - transaction moves DB from valid state to valid state
  - Isolation - result as if transactions executed sequentially
  - Durability - transaction remains effective once committed
- Implemented by locking resource, keeping partial copy til complete
