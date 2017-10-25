# Designing Secure Systems

## Computer Security (27/09/2017)

- Common criteria [ISO15408]
  - An international standard for computer security certification
- Protecting **digital assets** from **threats**

### Secure system definition
- Inability for attackers to achieve:
  - Adversarial goal (breaching any of:)
    - Confidentiality
    - Integrity
    - Authenticity
    - Availability
    - Accountability
  - Means of resources of the adversary
  - Access to the system

### Attacker motivation
- Profits and other benefits
- Political activism, terrorism
- Enjoyment
- Development of science and offensive technology

### Why things happen
- Bugs or not caring
- Programming is done with an absence of security considerations
- Economics/business
  - customers do not see/care about security
  - security measures sometimes reduce usability

### Risk management
- **Measuring** or/and **assessing** risks
- Developing strategies and solutions to **manage** risks:
  - **reduce/avoid** and **handle** risks

### Residual risk
What remains after defences are in place.

### Defenders
- Prevent
  - Deter
  - Hinder
- Detect
  - Monitoring/logging
  - Anomaly analysis
- Respond
  - Incident management
  - Forensics
  - Change procedures
  - Install new technologies

### Attack trees (04/10/2017)
- Formal analysis of all known attack venues
- Types of nodes
  - OR nodes (look like an arrow)
  - AND nodes (like an arrow but with a semi-circle inside)
- Labelled with probabilities or cost estimates
- Main goal is at the top

### Secrecy
- Create entry barriers for competitors
- Defend against hackers

#### Kerckhoff's principle
> The system must retain secure should it fall in enemy hands..

### Responsible disclosure
- Researchers should disclose vulnerabilities to the system owners and give "reasonable time" to fix them
- Benefits
  - Creates incentives for fixing vulnerabilities
  - Companies advertise bounties

## Principles of secure design (11/10/2017)

### 12 principles
- Inspired by **simplicity** and **restriction**
- Simplicity:
  - Makes designs/mechanisms easy to understand
  - Less to go wrong with simple designs
- Restriction:
  - Minimises power of an entity
  - Can only access info it needs
  - Can only communicate with other entities when necessary


**Principles**
1. Secure the weakest link
    - Security only as strong as weakest link
    - Attackers go for weakest point in a system
2. Defence in depth
    - Defend a system using several independent methods
    - Redundancy and layering to not rely on one defence
    - Consider: people, technology, operations
3. Fail secure
    - For a type of failure, access or data are denied
4. Grant least privilege
    - Every module can only access what it needs
    - Separation of privileges
      - Split system into pieces, each with limited privileges
    - Segregation of duties
      - Hard for one person to compromise security
5. Economise mechanism
    - Avoid overly complicating a system
    - Complexity leads to insecurity
      - Designer can't keep up
      - Harder to analyse security
6. Authenticate requests
    - Assume that operating environment is hostile
    - Put checks to ensure dependencies haven't been compromised/spoofed
    - Anticipate command-injection, XSS, etc.
7. Control access
    - Accesses should be checked
    - Up-to-date permission checking (not caching authority granting results)
8. Assume secrets not safe
    - An attacker will know how the system works
    - An attacker can find keys in binaries, use tools at disposal, etc.
9. Make security usable
    - Annoying security/product will be avoided by users
10. Promote privacy
    - Only collect personal info required
    - Store personal info securely, limit access
    - Delete personal data once purpose is served
    - Only store encrypted data
11. Audit and monitor
    - Record what actions were performed and by who
      - Disaster recovery and accountability
12. Proportionality principle
    - Maximise utility vs maximise security?
    - Maximise utility while limiting risks
      - to acceptable level
      - within reasonable cost


**Trusted:** Something that **could** break security policy
**Trustworthy:** Something that **will not** break security policy

## Cryptography (11/10/2017)
### Symmetric key encryption (e.g. AES)
- Encryption key used to encrypt and decrypt
- Typically use a block cipher
- Block modes such as "counter-mode"
- Needs randomness for security

### Hash functions (e.g. SHA2)
- Takes a message of any size and outputs a hash value of fixed length
- H(x) = H(y) implies x = y with huge probability

### Public-key encryption (e.g. RSA-OAEP)
- Public key (encrypt) and secret key (decrypt)
- Very difficult to retrieve secret from public
- Allows building encryption without needing key agreement

### Hybrid encryption
- No block modes for public key encryption
  - Would be too slow for long messages


- To encrypt long message _m_ using public key _pk_:
  - Choose random symmetric key, _k_
  - Encrypt _m_ with _k_: _c1_ = enc(_k_, _r1_, _m_)
  - Encrypt _k_ with _pk_: _c2_ = enc(_pk_, _r2_, _k_)
  - Send _c1_, _r1_, _c2_

### Digital signatures (e.g. Schnorr)
- Public and secret key
- Used for authentication (signatures)
- Signature checking algorithm only returns true if signature used correct secret key

## Authenticating websites and encrypting web traffic
Server has public key pk


1. Client->Server: "hello", random rb
2. Server->Client: pk, random rs
3. Client->Server: random pms, encrypted with pk

## Certificate authority model
### TLS
- Server sends public key
- Session encryption key established from server public key

### Certificate authorities
- Trusted third party that asserts that a public key belongs to a website
  - CA signs certificate to do this
- Browser knows the verification key to verify a public key's signature
- CA verification keys built into browser

## Device Security (18/10/2017)
- Physical security
- Firmware/OS security
- Application security


- Protects devices against
  - Malicious applications
  - Rootkits

### Malicious applications
Distributed using OS specific applications, designed to exploit the operating system vulnerabilities

- High success rate, masquerading as useful applications
- Often used to install more dangerous malware (e.g. backdoors, rootkits)

{Missing notes}

### How to prevent a rollback attack? (25/10/2017)
- Counter based version control
- Blacklist version control
- eFuses (physically blow when firmware is updated)
- Apple nonce based protocol: random unique value generated at every restore, signed by Apple

## Data Security
### Key encapsulation
- Encryption of large data slow with public key encryption
- Steps:
  - Encrypt data with symmetric key encryption
  - Encrypt symmetric key with public key
  - Send both encrypted data

### What you get/don't get from encryption
- Does:
  - Protect data while resting
  - Protect data from apps that don't have access to the keys
  - Protect data if stolen or accessed
- Doesn't:
  - Prevent data loss
  - Make the system more resilient
  - {Missing point}

### Disk based encryption
(Stuff about what's encrypted and what's not.. e.g. kernel not encrypted)

### Storing the key
- USB stick
  - Easy
  - Requires USB on system
  - Vulnerable to stealing
- TPM
  - Difficult to set up
  - Transparent
  - Protected from stealing

### {Missing notes}

### Bitlocker
{Missing notes}
