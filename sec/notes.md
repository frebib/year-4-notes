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

