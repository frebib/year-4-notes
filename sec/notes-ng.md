# Network Security

# Assets, Threats, Risks
TODO: Recap and focus on networks and network connected equipment

## Default Deny
- By default, block all access
- Have rules to allow certain connections
- Stops business moving quickly
- Doesn't work for IoT applications

## Default Permit
- Whole network exposed to outside world
- Individual assets protected on case-by-case basis
- Firewall removes noise + bad stuff, not trusted to be complete

# Host security

## Logging
- Logs should be complete, accurate, trustworthy, secure
- Logging is cheap (takes up little space)
- Can be great for debugging security failures
- Must be complete, accurate, trustworthy, and secure
- Good to put them away from the device generating the logs

## Patching
- Vulnerabilities found all the time
- Important to patch if security critical
- Patching can break machines, but the more often you update the less likely it
  is for patches to be massive and make big breaking changes

## Service Minimisation
- More services, more attack vectors
- Options, higher is better:
  - Don't install service
  - Don't run service
  - Run locally
  - Run protected from network
  - Run exposed to network
- Can use `nmap` etc. to find running services

## Least Privilege
- Run each process with the least amount of privileges
- Don't run as root
- Might need root for:
  - Opening ports <1024
  - Write to user files
  - Both can be mitigated

## Virtualisation

### Hypervisors
- Type 1
  - Host runs hypervisor, which manages guest OSs
  - Guest OSs are unmodified
  - Guest OSs run own networking connected to virtual bridges
- Type 2
  - Host runs base OS, which runs hypervisor, which manages guest OSs
  - Networking might go through base OS

### Para-virtualisation
- Need OS support in VMs
- Hypervisor will provide a simpler API for drivers etc., and pass through
  directly to hardware

### Jails, Zones, Containers
- Jails is FreeBSD, zones == containers, will use containers to refer to all
- Host OS runs one kernel, but a subset of processes are isolated from the rest
- Collection of isolated processes is part of the container
- Container has its own `init`, filesystem, sometimes networking
- Cheap, lightweight, easy to manage
- So far, good for security, but a large attack space to explore

# Defence and Attack

## Defence in Depth vs. Multiple Shallow Defences
- 1 strong defence vs. 10 weak defences
  - Are 10 weak defences independent?
    - If so, adding more can't hurt
    - If breaking one makes it easier to break the others (i.e. by getting into
      the network), best to not use the defence
  - If an attacker can break 1 weak defence, likely to be able to break 10

## Attack trees
- Build a tree with attackers goal as the root
- Each child is a way to achieve the parent's goal
- Break down problem until you find a reasonable attack vector
- Possibly not a strict "tree", one child node can help with several parent's
  goals

## Side-Channel and Subsidiary Protocols
- Attack other protocols which you would not thing integral to security
- e.g. DNS
- TODO: Look at specific DNS attack mentioned in slides

# Firewall

## Layers of Network Components
- Hubs
  - Copy ethernet packets from one interface to all interfaces
  - Done electronically
- Simple Bridges
  - Copy ethernet packets, dropping malformed ones
  - Provide no protection apart from flooding attacks
- Switches
  - Copy packets if source and host are on other sides
  - Stops attackers snooping on data on other side of switch
- Filtering switches
- Routers
  - Looks at IP header
  - Chooses correct interface
  - Doesn't propagate broadcast packets
- Filtering routers/firewalls
  - Look at TCP/UDP ports and block/pass based on those values
  - Minimum requirement to be a security component
- Stateful firewalls
  - Look at the state of TCP connections
  - Tracks sequence numbers, sensible responses, etc.
  - Blocks complex attacks on TCP
- Deep packet inspecting firewall
  - Looks at whole packet
  - Virus scanner
  - Block encryption it doesn't know about
  - Unethical?

## Host vs. Network
- Can run on host
- But if host is compromised, then firewall is too (and vice versa)
- Better to run dedicated, segmented firewall machine

## Design Issues
## Testing
## IPv6 Issues
## Statefullness
- Can look at states of TCP connections
- Can overcome attacks on TCP like sequence numbers, SYN-flooding
- Can provide canonical TCP connections to end users, meaning rarely tested code
  paths won't be executed

# Firewall Implementation
## Linux vs. Everything Else (IP Stack v Interfaces)

# Network IPS/IDS
## Concepts and Limitations
## Host IDSes
## Tripwire
## etc

# Admission control
## Wireless authentication
## Radius for 802.1x
## WPA2/PSK
## WPA2 Enterprise.

# Firewall Alternatives
## Data Diodes
## Proxies
## Other Firewall Alternatives

# Web Server Security
## HSTS
## Content-Security-Policy

# Application security
## Application Design
## Firewall Friendliness
## NAT Friendliness

# Application security
## TLS and authentication via certificates
## OTP Tokens

# Specific Attacks
## Denial of Service
## Amplification Attacks
## Mitigations
## Egress Filtering for “Good Network Citizens”

# Attacks on DNS

# Certification issues (HPKP and its problems, CAA, etc).

# VPNs
Concepts and components

# IPsec
- Two modes of encapsulation
  - Tunnel, transport
- Two modes of use
  - AH (authentication), ESP (encryption)
- Two mechanisms for keying
  - Static (e.g. PSK) and dynamic (IKE)
- Layers
  - Data plane transformation has to happen at wire-speed
    - Big focus on speed
  - Management layer, i.e. key exchange, much less demanding
  - Transformation in kernel, key exchange in user-space
- Problems
  - Implementation is complex
  - Key management issues
- Implementations: KAME, FreeS/WAN

## AH vs. ESP
- AH (authentication header)
  - Integrity of payload and immutable parts of header
  - Keyed hash
  - Ensures it comes from where it claims to have come from
- ESP (encapsulated security payload)
  - Provides encryption and optionally payload integrity
- AH+ESP
  - Full integrity and encryption
  - Dropped in favour of other mechanisms that do the same basic job
    - e.g. encryption that has authentication built in

## Transport vs. Tunnel
- Transport
  - When both nodes speak IPsec
  - Packets transformed directly
  - IP header, ESP/AH header, payload
- Tunnel
  - Communication between routers that carry traffic
  - Packets are encapsulated (IP-in-IP)
  - IP header transformed too
  - IP header, ESP/AH header, IP header for end system, payload
- Security Parameters Index (SPI)
  - SP defines algs/keys in use for security associations
  - Lookup in SPI table when handling packets
  - AH packets contain SPI for looking up key
- There are sequence numbers to prevent replay

## Internet Key Exchange (IKE)
- Based off DH
- Can use: PSK, public keys, certificates
- Main mode
  - Five exchanges
  - Conceals each parties' identities
- Aggressive mode
  - Three exchanges
  - Sends identities before secure channel is set up
- SA proposals
  - Say what crypto algorithms you will support for the key setup, so can be
    slow

### IKEv2
- Four packet exchange for set up
- Better documentation/standards

# VPNs
## Protocols
## OpenVPN/SSL-VPN
## IPsec
## Extensions to IPsec
## IPv6 issues

