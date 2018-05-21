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
TODO

## Testing
TODO

## IPv6 Issues
TODO

## Statefullness
- Can look at states of TCP connections
- Can overcome attacks on TCP like sequence numbers, SYN-flooding
- Can provide canonical TCP connections to end users, meaning rarely tested code
  paths won't be executed

# Firewall Implementation
## Linux vs. Everything Else (IP Stack v Interfaces)

# Network Intrusion Detection/Prevention System (IDS/IPS)
- Get copy of traffic from routers
- Examine full packets, headers + payload
- Look for
  - Recognised malware
  - Unrecognised encryption
  - Attacks
- Do this by
  - Matching payloads against known attacks
  - Matching behaviour against known attacks
  - Matching heuristics, e.g. loss in network performance, lots of failed
    connections
- IDS will report the packets, IPS will drop them automatically
- Deployment options
  - Can deploy behind firewall, as if we're filtering it out already, who cares?
    - Fast reactions when using IPS
  - Can deploy in front of firewall, for research purposes
  - Can deploy in network, with all traffic mirrored to it (configured in
    router)
    - Will be slower, and could drop packets when router is buffering
- Lots and lots of data, so discard as much as you can as early as you can

## Host IDS (HID)
- Run on a host machine to detect intrusion
- Often relies on reading logs, which are brittle

### Tripwire
- Take hashes of critical files, and compare then with real files periodically
- Problem: if attacker can change files, can't they change the stored hashes?
- Still useful against naive attacks

### OSSEC
- Tripwire + log analysis + filtering
- e.g. update firewall after multiple failed logins
- fail2ban can also do this, but should be careful about locking out users

# Admission control
## Wired Networks
- You know where the wires are
- Tapping wires requires effort and is detectable
- Tempest attacks are hard
  - Looking for radiation from a wire
  - Fibre makes this risk essentially zero
- Can do MAC filtering
  - Easily bypassed

### 802.1x Authentication
- Authentication over ethernet
- Client supplies username and password
  - Or proves ownership of certificate
- Pre-auth, port is restricted to auth only, or VLAN
- Can do "posture analysis", checking how patched a device is
- Problems
  - Difficult to generalise to printers/servers/webcams
  - Who has the keys? Device or user? Can malicious user copy keys to other
    devices?
  - Gets complicated with multiple switches, which one to auth to?
  - Trivially bypassed through carefully timed switching of MAC addresses
- Benefits
  - Posture analysis is useful
  - Requires attacker to do something overt

## Wireless Networks
- None of the inherent security of wired networks

### Wired Equivalent Privacy (WEP)
- Everyone has shared key (40 bits, later 104 bits)
- Encrypt packets using RC4
- All stations with key can see all packet contents
- Broken
  - Attacker can attempt to obtain key
  - Generating random IVs very difficult in embedded devices
- RC4
  - Uses key and IV to generate evolved keystream of bytes, which are XOR'd with
    message to form cipher text
  - Can either recover key, or recover evolved keystream
  - Inject unencrypted packets into the network, and then see how the network
    encrypts them

### Wi-Fi Protected Access (WPA)
- Emergency interim fix to WEP
- Add sequence numbers
- Better key mixing
- Integrity checks
- Sill weak

### WPA2
- Initial secret (PSK, or per-user login)
  - Generates ephemeral key used for one session (~1hr)
- Uses AES128
- Needs new hardware
- Can't see other's traffic
  - But can use special key for broadcast traffic

#### WPA2 PSK
- Use a pre-shared key
- Mixes in SSID to help prevent dictionary attacks
- No forward secrecy

#### WPA2 Enterprise
- Per-user key is negotiated
- Compromising key only compromises that key's user

### Wirless Security Objectives
- Authentication
  - Don't want neighbours using up bandwidth
- Confidentiality
  - Don't want others on my network to see my data
- Integrity
  - Don't want MITM attacks

### Wireless Protected Setup
- Bad
- 8 digit pin
- Split into 2 4s, each verified separately

# Firewall Alternatives

## Proxies
- Real client connects to stub server, stub client connects to real server
- Proxy can inspect protocol

## Data Diodes
- One-way connection
  - So sender is still protected from network, but can still send data
- Queue in the middle that buffers data and then scans it
- Not good for voice

## Other Firewall Alternatives
TODO: SBCs

# Web Server Security
## HTTP Strict Transport Security (HSTS)
- States that HTTPS will be on this domain for the next X time units (should be
  around a year)
- Browser will cache HSTS response, and if it comes back to the website and it
  hasn't got HTTPS, fail the connection
- Means attacker must fake the first access to website
- HSTS Preload in Chrome etc. means that even the first connection isn't good
  enough

## HTTP Public Key Pinning (HPKP)
- States that domain will always use one of these public keys for the next X
  time units
- Stops fake certificates
- Tricky to set up, need to keep in mind future public keys

## Content-Security-Policy
TODO: Not mentioned in slides

# Application Security
- Only one TCP connection
- If more needed, each goes through full authentication

TODO: What else is needed here?
## Application Design
## Firewall Friendliness
## NAT Friendliness

# Application security
## TLS and Authentication via Certificates
## OTP Tokens

# Specific Attacks
## Denial of Service
- Killing applications/machines/networks
- Can be done in variety of ways
  - Just sending lots of packets
    - Need high speed connection/lots of low speed connections
  - Exploiting stuff like allocating on SYNs
  - Relying on more complicated knowledge of applications
- If attacker is idiot, can just filter them out
## Amplification Attacks
- Small request, big response
- Forge source IP
- To avoid being the middle man:
  - Default deny, rate limiting, paged responses (?)

## Mitigations
- Cloudfare will proxy traffic through them
  - Can make attacker run complex Javascript before getting to your server
  - If there's HTTPS, requires Cloudfare to have certificate
- Host your side on a CDN, rely on them to withstand the DoS
- Anycasting
  - Advertise of BGP multiple locations hosting that IP
  - Attacker then has to take out each of those locations
  - Can sort of be done through multiple DNS A/AAAA records, but doesn't give
    geographic importance
- Ingress filtering
  - All packets leaving network should originate in the network
- Egress filtering
  - All packets entering the network should not originate in the network

# Attacks on DNS
- Kaminsky attack
  - Pretend to be name server, and reply with fake DNS response
  - Guess the query ID number, which is only 16 bit, so doable
  - "Solved" by doing over several ports, so that adds entropy to QID
  - Don't NAT DNS, because it will break the port fix
- Cache poisoning
  - Get corrupt data into DNS cache
- Never run recursive and authoritative name servers in the same instance
  - TODO why?

# Certification Issues (HPKP and its problems, CAA, etc).

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

# Virtual Private Network (VPN)
- IP-in-IP to get packets between parts of the virtual network
  - Original IP packet becomes payload in new IP packet
- Not secure by itself
- Can use IPsec
- Can use SSL-VPN
- Networks address space should not clash
- Can connect different sites of the same company, without exposing internal
  applications

## Protocols
TODO: What goes here?

## OpenVPN/SSL-VPN
- SSL-VPN
  - Client-less option
    - Systems provide access to HTTP resources via an SSL connection between
      browser and VPN server, proxying through to original server
    - Not technically a VPN
    - Can have problems, due to all resources coming from single domain
      - XXS, cookies issues, etc, if any one of the resources is compromised
  - SSL forwarding
    - Run a local app listening on `127.0.0.1:port`, and are tunnelled to
      `server:port`
- OpenVPN
  - Uses auth mechanisms from SSL (OpenSSL)
    - i.e. certificates
  - Runs over TCP/UDP
    - Means it's ok for firewalls

## IPsec
## Extensions to IPsec
## IPv6 issues

## SSL VPN

## Point-to-Point Protocol (PPP)
- Layer 2 Tunnelling Protocol (L2TP)
  - Sends packets as UDP containing tunnelled data
  - Used to tunnel PPP
- PPP derived from HDLC
- Sends IP packets down serial lines
- Has its own auth mechanism
  - Allows username/password
  - Can negotiate MTU, IPs
- No encryption in PPP and L2TP
  - But we can use IPsec
  - Complex to set up

