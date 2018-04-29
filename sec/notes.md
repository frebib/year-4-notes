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

# Transport Attacks
- Filter according to IP address and port rules
  - e.g. only accept traffic to the DNS server from some network
- Doesn't work sometimes, because attacker has control over the packet it sends,
  and therefore can change the source address
  - However, responses will be sent to the wrong place

## UDP Attacks
- Can send packets and hope for buffer overruns
- DoS
- Use services that are authenticated by source
  - e.g. syslog: send logs to UDP port 514, it gets appended to a log file
- Amplification attacks
  - Ask for a lot of data, and set return address to a target
  - Target gets sent lots of data
- Broadcast attacks
  - e.g. send echo request to broadcast address with forged source, and forged
    source will recieve a packet from every machine

## TCP Sequence Numbers
- Repeated TCP sequence numbers (e.g. all start at 0) means that small
  connections can get confused
  - TCP checksum is per-segment, so will not detect segments being swapped
- This means that the start sequence number is set randomly
- But if we can predict sequence numbers, can ACK data that we can't see
- Means we can insert arbitrary data
- ...provided we can guess start sequence number

## Handshake Offload
- Attacker sends lots of SYNs, and no further packets
  - Resources alloc'd for the connection, and never used
- Can forge source address, harder to track
- Solution:
  - Do SYN, SYN/ACK, ACK in firewall
  - Firewall has own initial sequence number
  - Offset applied to all packets passing through firewall for this connection
- Modern OSs will handle this themselves, but if you need to run old software,
  the above solution is good

## Firewall Tasks
- Drop packets from outside which have inside IPs
- Drop packets from outside which have odd IPs (e.g. loopback)
- Drop packets from inside which have outside IPs
- Rate limit
- SYN, SYN/ACK, ACK in firewall
- Re-randomise ISN

# Isolation
- Each process should be run with least privileges
- Need root access for low ports
- Need to isolate machines from each other
  - If attacker gains access to one process, they can mess with others on the
    machine
  - Can be done through running different services as different users
  - Ideally different machines (including VMs/containers)

## Virtualisation
- Type 1 hypervisor
  - Host runs hypervisor
  - Usually linux
- Type 2 hypervisor
  - OS running on host
  - This OS runs all the VMs
- Para-virtualisation
  - OS slightly modified
  - Uses special network/graphics/other drivers to pass to VMs
- Zones/jails/containers
  - Machine runs one kernel
  - Subset of processes are isolated with their own init, filesystem, networking
  - Lightweight
  - Easy to manage
  - Security looks good, but hard to audit

## `chroot()`
- `chroot(/some/dir/)` makes all processes onwards see `/some/dir/` as `/`
- Can't `cd` out of `/some/dir/`

# Attack Trees
- Build a tree, with attacker's goal at the top
- Children are ways to achieve parent's goal
- Should keep attack vectors separate, so that "hacking" one thing doesn't give
  the attacker multiple vectors
  - e.g. firewalls should be on separate machines

# Network Elements

## Spectrum of Boxes
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

## Intrusion Detection/Prevention Systems (IDS/IPS)
- Gets copy of data from switches/routers
- Examines whole packets for worrying conditions
- Reports attacks, or tells routers to drop traffic
- Will do things like checking SMTP commands

## Switch Authentication
- Configure switch to only accept certain host
- e.g. set MAC address, block other ones
- Does not scale well
- Can be bypassed through MAC filtering, but does require attacker to
  proactively do something suspicious
- Can also run 802.1x over ethernet, not widely done

# Firewalls
- Looks at packet headers, and blocks/passes based on some policy
- Not based on packet contents
- Usually live on:
  - Routers
  - Dedicated firewall machines
  - Computers acting as routers
  - Computers looking after themselves
- Keep unusual/unwanted packets away from applications
- They can not:
  - Detect malware etc.
  - Detect misuse of legitimate protocols
- Don't do anything that an OS can't do, but
  - Provide smaller attack vector
  - Only have to audit one machine for it
  - Use hardened OSs
- Track TCP state
  - Discard packets that don't line up, should happen anyway but can help
    prevent untested code paths being run etc.
  - Helps with DoS attacks

# Proxies
- Make request to stub server
- Stub server puts in queue
- Stub client reads from queue
- Stub cilent sends request to real server
- Issues with VOIP, too much delay

# Wired/Wireless Security

## Wired Networks
- You know where the wires are
- Tapping wires requires effort and is detectable
- Tempest attacks are hard
  - Looking for radiation from a wire
  - Fibre makes this risk essentially zero
- Can do MAC filtering
  - Easily bypassed

## 802.1x Authentication
- Client supplies username and password
  - Or proves ownership of certificate
- Pre-auth, port is restricted to auth only, or VLAN
- Can do "posture analysis", checking how patched a device is
- Problems
  - Difficult to generalise to printers/servers/webcams
  - Who has the keys? Device or user? Can malicious user copy keys to other
    devices?
  - Gets complicated with multiple supplicant support
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

# Intrusion Detection Systems (IDSs)
- Look at all traffic passing through a network
- Access to headers, payloads, timing, etc.
- Triggered by:
  - Patterns in packets, i.e. matching payloads of packets against signatures
    of known malware
  - Behaviour: matching against known behaviours of malware, e.g. lots of
    probing
  - Heuristic: matching against changes in network performance, or obviously
    dubious activity
- Possible set ups
  - Behind firewall (monitors traffic that makes it through the firewall)
  - In front of firewall (for research purposes)
  - Mirror port: most switches has ability to pass all traffic to a mirror port,
    used for debugging
- Lots of false positives, many rules are for old irrelevant attacks

## Host IDSs
- Tripwire
  - Take hashes of critical files
  - Compare with files on disk periodically
  - How do you secure the hashes/kernel/etc?
- OSSEC
  - Similar to tripwire
  - Log analysis, filtering and response

