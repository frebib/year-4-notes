# Network Security

# Introduction
- What are we protecting?
  - Confidentiality
  - Integrity
  - Availability
- What are assets?
  - Data and services
- What is our objective?
  - Secure data so that it can be trusted by authorised users

## Default Deny
- By default, block all access
- Have rules to allow certain connections
- Stops business moving quickly
- Doesn't work for IoT applications

## Default Permit
- Whole network exposed to outside world
- Individual assets protected on case-by-case basis
- Firewall removes noise + bad stuff, not trusted to be complete

# Logging
- Logging is cheap (takes up little space)
- Can be great for debugging security failures
- Must be complete, accurate, trustworthy, and secure
- Good to put them away from the device generating the logs

# Patching
- Vulnerabilities found all the time
- Important to patch if security critical
- Patching can break machines, but the more often you update the less likely the
  less likely it is for patches to be massive and make big breaking changes

# Service Minimisation
- More services, more attack vectors
- Options, higher is better:
  - Don't install service
  - Don't run service
  - Run locally
  - Run protected from network
  - Run exposed to network

