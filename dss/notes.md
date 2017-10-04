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

## Principles of secure design

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
5. Economise mechanism
6. Authenticate requests
7. Control access
8. Assume secrets not safe
9. Make security usable
10. Promote privacy
11. Audit and monitor
12. Proportionality principle


