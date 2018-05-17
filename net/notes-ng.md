# Networks

# Transmission (all at a very high level only)

## Asynchronous Transfer Mode (ATM)
- Packets of 48 bytes, 5 byte header
  - Due to echo cancellation
- Virtual circuit
- Used mostly in telco core networks
- Not used now because of cheap ethernet

## Wave Division Multiplexing (WDM)
- How data is transmitted across fibre cables
- Use different colour light (frequencies/lambda) to transmit multiple streams
  down a single fibre
- Dense/Coarse WDM (DWDM/CWDM)
  - Coarse: 20nm difference between adjacent channels, but can go further
  - Dense: 0.8/0.4/0.2nm difference between adjacent channels
- Can go up to 10Tbps+
- Telcos do ethernet straight over WDM
- Long range

## Synchronous Digital Hierarchy (SDH)
- How data is transmitted across fibre cables
- Can run inside of WDM
- Deals in "trails" (streams) of data
- Trails are 2Mbps+
- Multiplexes these trails into STM1/4/16/64 which has speeds of
  155Mbps/622Mbps/2.4Gbps/10Gbps
- Extract and insert individual 2Mbps trails into the total stream
- Still mostly used for long-haul internet traffic

# Ethernet
TODO: Add ARP section

## Switching/Bridging
- Repeater
  - a.k.a. hub
  - Amplify data transfer between multiple ethernet wires
- Bridges
  - Puts packets into a queue and waits to transmit them
  - Checks if ethernet frames are broken
  - Stops collisions between interfaces
- Switch
  - Look at ethernet packet to determine which interface to send a packet down
  - Stops collisions between interfaces
  - Attempts to only send packets down correct interfaces (reduce congestion,
    some improved security)
- Cut through (aggressive) switch
  - Regular switch looks at whole packet
  - Cut through switch looks at header and forward immediately
  - Will not check the checksum
  - Less latency, but will forward broken frames

## Collisions
- Only relevant when transmitting down a single wire (perhaps joined by a
  repeater)
- Only one sender on the wire at any one time
- Senders must wait until no one else is sending on the line
- Detecting collision
  - As you transmit, if you listen back and don't see what you sent, then
    someone else is sending
- When a collision happens
  - "Jam" the network by sending a specific bit pattern
  - Whole network must know about the collision before the packet has finished
    being sent, so they don't think the packet is valid
  - This created the minimum packet size of 64 bytes
- Recovery from collision
  - On the `n`th attempt to retransmit, chose a random number `k` from `[0, 2ⁿ]`
    and delay `512k` bit periods before trying again
  - After 10 attempts, give up
  - Quality of RNG does not matter

## Broadcasting
- When broadcasting, send to MAC address `FFFF...`
- Sends to everyone

## Virtual LANs (VLANs)
- Can put multiple networks through the same wire
  - Useful because it logically separates networks without the need to have
    multiple wires
- Ethernet frames have an optional `tag` field (0-1023, typically 0-4095)
- Differentiate between different "networks" going over the same wire
- OS sees them as two separate networks
- Can have untagged ports
  - Don't need to understand VLANs
  - Can forward these ports into other VLANs

### VLAN Security
- Adds no security, nodes on VLAN A can still see traffic from VLAN B
- Can be used for security in terms of segregation of networks, to be filtered
  out before you send to insecure locations

## Link Aggregation (LinkAgg)
- Multiple physical interfaces, one virtual interface
- Can be thought of as inverse of VLAN (VLAN⁻¹)
- Fast failover
  - If a physical interface goes down, the virtual interface persists over the
    remaining physical interfaces
- Efficient multiplexing and load spreading
- However, only goes as far as the nearest switch
- LACP is an example implementation of LinkAgg

### Using LinkAgg with VLANs
- Deliver two+ networks over two+ cables
- Full load balancing for both networks
- Full failover for both networks

## Misc

### Random early drop
- As buffer fills up, likelihood of intentionally dropping packet increases to
  100%
- Stays near zero for majority of time
- Exponential

### Topologies
- Single coaxial cable
  - Big, thick, cable
  - Drill into to access
  - Not used anymore
- Token Rings
  - Pass a "token" between nodes, if you hold the token you can transmit
  - In theory, bounded latency: `num_nodes * max_packet_period ± fudge`
  - Issues with token loss/creation
  - Station failure
- Slotted Rings
  - Empty data frames pass around the network, and can be filled by nodes
  - Requires a minimum length of network
    - Resulting in long lengths of gable coiled under the floor
- Modern topology
  - Use twisted pair cable
  - Single wire for each node connected to some router

# Internet Protocol (IP)

## Addressing
- IPv4
  - 32 bits, 4 bytes for an address
  - Running out of addresses because of wasteful allocation
    - e.g. A whole `/8` allocated to loopback
  - Classful
    - Class A/B/C
    - Class A starts `0...`, bits first byte define subnet
    - Class B starts `10...`, bits first two byte define subnet
    - Class C starts `110...`, bits first three byte define subnet
- IPv6
  - 128 bit addresses
  - Although minimum allocation unit is `/64`, but `2^64` is still massive
  - Billions of IP addresses per person
  - TODO: Revise some IPv6 reservations

### Address Allocation

#### Static
- Configuration file that states IP address on each node
- Naive, no mechanism for dealing with collision

#### bootp
TODO: Necessary?

#### Dynamic Host Configuration Protocol (DHCP)
- Lease an IP address from the DHCP server
  - A lease has a TTL
- Typical flow:
  - Client broadcasts `DHCPDISCOVER`
  - Server checks for available IPs, and replies `DHCPOFFER` with a list of
    available addresses
  - Client replies `DHCPREQUEST` with chosen address
  - Server replies `DHCPACK` to ACKnowledge allocation
  - When client wants to release the address, send `DHCPRELEASE`
- Can have multiple DHCP servers advertising different sets of addresses, client
  has to chose
- DHCP server can just hand out static IPs instead of from a pool of dynamic IPs

##### DHCP Redundancy
- If a DHCP server goes down, everything breaks
- If we have multiple networks:
  - Can have multiple DHCP servers, which means multiple things can go wrong
  - Can have shared DHCP server, but doesn't scale, and security nightmare as
    if attacker breaks into DHCP server they can access both networks
  - Or can use DHCP relay
    - Single DHCP server linked to router
    - Have a DHCP relay on each network
    - Relay contains no state, can be rebooted, knows the main DHCP server's IP
    - Relay will listen for DHCP broadcasts, and forwards on to known DHCP
      server IP
    - Server responds to relay

#### Stateless Address Auto-Configuration (SLAAC)
- Used for allocating IPv6 addresses
  - Can use DHCPv6, but has the same problems as DHCP
- Typical flow:
  - Router broadcasts router advertisement packets
  - Connected node will take the network prefix (`/64`, 64 bits) and concatenate
    their 48 bit MAC address plus other stuff, making a 128 bit IPv6 address
  - Use this IPv6 address without any other negotiation
- Problems
  - No DNS servers are communicated without DHCP
    - Can just use DHCP on top of SLAAC to discover DNS servers etc.
    - IPv6 defines the advertisement, which contains some flags:
      - `M` flag means "managed", i.e. that the addresses are managed and node
        should use DHCPv6
      - `O` flag means "other", i.e. that the node can chose its own address 
        using SLAAC, but still can use the DHCPv6 server for other information
    - When DHCPv6 is used like this, it is essentially stateless
  - Privacy: MAC address is embedded in public address, so you can be tracked
    across networks
    - Solution 1: random IPs whenever a new IP is required
      - This makes logging local networks difficult
    - Solution 2: random IPs seeded by the network prefix, some static
      information (e.g. MAC, network SSID), and perhaps a counter to deal with
      clashes
    - Problem is overstated, it is hard for an attacker to track across public
      internet

## IPv4 and v6 Subnets and Prefixes

### Classless Inter-Domain Routing (CIDR)
- Each network identifier also has a subnet mask of the same length
- Subnet mask describes what part of the network identifier corresponds to the
  network prefix, and the rest is the "host suffix"
- Subnet mask is described as `/16` which means 16 binary 1s followed by 16
  (32 - 16) binary 0s
- e.g. for network `192.168.0.0/16`:
  - `192.168` is the network prefix
  - `0.0` is the "host suffix"
- Class A is a `/8`, B is a `/16`, C is a `/24`
- Works similarly for IPv6

## Routing

### Packet Switching
- Have a mapping of `network_identifier, subnet_mask` to an interface
- To determine if an IP address belongs in a subnet, you check if `host_ip &
  subnet_mask == network_identifier`
- Forward packets down the correct interfaces

### Virtual Circuits
- Ask network to set up a "circuit" of routers between source and destination
- Get back a virtual circuit identifier
- Associate each packet with identifier

## Routing Protocols
- Two types
  - Distance vector (RIP, BGP)
  - Link state (OSPF)

### Routing Information Protocol (RIP)
- Each router advertises how far away it is from every destination
  - e.g. "2 away from network A, 5 away from network B"
  - Adverts are sent every 30 seconds
- Each adjacent network gets RIP advertisement, and increments the distance by
  one, and sets these connections to be its own, e.g.:
  - Router A advertises to router B: "2 away from network A, 5 away from network
    B"
  - Router B can now advertise "3 away from network A, 6 away from network B"
- Distance is 0-16, where 16 means unreachable
- Can only use for networks with a small diameter
- Problem with links going down:
  - Router A advertises to Router B "1 away from C"
  - Router B knows it is 2 away from C
  - Link between Router A and Router C goes down
  - Router B advertises to Router A "2 away from C"
  - Router A thinks it is 3 away from C
  - Continues until reach 16, takes about 4 minutes to converge with 30 second
    advertisement timing
- Solutions:
  - Flash update
    - Send advertisement as soon as update happens to speed up convergence
  - Split horizon
    - Only advertise links down interfaces where you didn't receive the link
    - Avoids problem completely, apart from...
    - Doesn't solve problem with loops
  - Poison reverse
    - Similar to flash update, but also send updates when links fail (advertise
      16)

#### Convergence Properties
Converges slowly because updates might need to propagate across the network
multiple times

### Open Shortest Path First (OSPF)
- Routers elect a "designated router" (DR) and a "backup designated router"
  (BDR)
- All routers advertise link states
  - Instead of advertising "2 away from C", advertise "Link from A to B, link
    from B to C"
  - Also describes state of links (e.g. bandwidth, latency, reliability)
- DR and BDR build minimum spanning tree based of link states
- DR and BDR build routing table from spanning tree and distribute it among the
  routers

#### Areas
- Typical OSPF operation works with smaller networks
- Can wrap collections of routers in OSPF "areas"
- N.B.: Areas can not be stacked, there's only two layers: an area, and
  everything
- Typical OSPF operation is then used to route between the areas
- Each DR of an area will advertise its links as a subnet

#### Convergence Properties
Converges much faster then distance vector algorithms as full link information
is propagated, meaning only one propagation needs to happen

## Network Address Translation (NAT)
- Wrap range of private IP addresses behind one public IP address
- When a private node communicates with a public node, the NAT establishes a
  port and address mapping for that connection, e.g.:
  - Private node `1.2.3.4:1234` send packet to public server `8.8.8.8:53`
  - NAT router `4.3.2.1` maps port `1234` to `4321`, and sends to public server
    `8.8.8.8:53`
  - Public server `8.8.8.8:53` replies to NAT router `4.3.2.1:4321`
  - NAT router recognises port `4321` and maps packet to `1.2.3.4:1234`
- Port mappings live for the duration of a TCP connection, from three-way
  handshake to `FIN` packets
  - For UDP, connection starts on first packet, and has a timeout of 10 seconds
  - There will be a timeout for TCP too, in case `FIN` packets aren't seen
- Can also set up static port forwarding, so that public server can establish
  connection to private node
- Breaks end-to-end principle of the internet

# UDP
- Lossy, unordered, datagram-based transmission
- No guarantees on delivery

## Advantages and disadvantages
- Prioritises latency over correctness
  - Means quick connection setup
- No reliability

# TCP
- Lossless, ordered, stream-based transmission
- Every packet is acknowledged
- etc.

## Mechanisms and operation
### 3-way Handshake
- Client chooses seq# `x`, send `(SYN, seq=x)`
- Server chooses seq# `y`, send `(SYN+ACK, seq=y, ack=x+1)`
- Client acknowledges, send `(ACK, seq=x+1, ack=y+1)`

### Close Handshake
- `FIN/ACK/FIN/ACK`
- `FIN-ACK/FIN-ACK`
- `FIN/FIN-ACK/ACK`

## Sequence numbers
- 32 bit
- Identify the index of the *byte*, not the packet

## Receive windows
- Instead of waiting for each acknowledgement, allow several unacknowledged
  packets in transit at any one time

### Go-Back-N
- If a packet acknowledges sequence number `X`, it is saying that all packets
  with sequence number `Y < X` have been received successfully
- If packets 1, 2, and 4 are received, then we acknowledge 2, 3, and 3
  - We always acknowledge the next packet we expect
  - If we receive a packet out of order, we resend the previous acknowledgment
  - Hence sending acknowledgments for 2, 3, 3
- Maintain a timer for all packets, if we receive no acknowledgements, we resend
  all data after the last acknowledgement

### Selective repeat
- Each packet is acknowledged separately
- Maintain a timer for each packet

## Slow start
- LAN is faster than WAN mainly
- If we advertise large receive window, then the router has to churn it out
  slowly
- This could lead to router running out of memory
- So what we do, is send one packet, then two, and then increase some amount
  every time we get an ACK (usually exponentially), until we hit rec window
- If packets are dropped, we multiplicatively decrease how much we send

## Window scaling
- Receive window limited to 64k (16 bits)
- Very low limit
- To solve this, there's a scaling value, 4 bits, max 14, default 7
- `new_window_size = window_size << window_scale`
- Increases window size to `2^(16+14) = 2^30`

## Timestamping
- Add timestamp to packets to calculate round-trip-time
- Also used for PAWS

## Protection Against Wrapped Sequence (PAWS)
- 4GB worth of sequence numbers, so if you want to send more than 4GB there's
  no way to distinguish between new and old packets
- We add a millisecond timestamp to the headers in order to distinguish
- This timestamp can also be used to measure round-trip time
- Also allows us to reliably measure round-trip-time

## Multipathing
- Allows multiple paths to be used by one TCP connection
- e.g. Wifi and 4G together
- Performance + fail safe
- Very new
- Say `MP_CAPABLE` in initial connections
- Say `MP_JOIN` over different interface(s) with MAC to join initial connection

# DNS
## Concepts
## Resource Records (RR)
### Sets
- Collection of RRs relating to the same domain
- Different types (`A`, `AAAA`, `PTR`, etc.)
- Can have multiple of the same type
  - If two `A` RRs, client will round-robin chose which response to use

## Basic Operation
## Recursive and Authoritative Servers
## Caching
- Recursive DNS servers will cache responses from authoritative servers
- Cache lives as long as a TTL field in the resource records

# Higher layer protocols (Basic operation of)

## Hypertext Transfer Protocol (HTTP)

## File Transfer Protocol (FTP)
- Old protocol for transfering files
- Requires lot of engineering in NATs
- Old mechanism:
  - Client requests using server's port 21
  - Request contains open port on client
  - Server sends file back to client on port, from server port 20
- New mechanism:
  - Server listens on high port
  - Client calls to it from high port
- Active mode
  - Client connects to server on `:21`
  - Client opens a port on `:P` where `P > 1024`
  - Client tells server selected `:P`
  - Server sends data to `:P`
- Passive mode
  - Client connects to server on `:21`
  - Server opens a port on `:P` where `P > 1024`
  - Server tells client selected `:P`
  - Client receives data on `:P`

## SMTP
- Sending email
- Extensions for auth, encryption, etc.
- Mail user agents (MUAs) talk to mail transport/submission agents (MTAs/MSAs)
- MUA is a email client, or browser client
  - Can communicate through SMTP or an API
- MTA/MSAs are responsible for storing/retrieving data
  - MTA/MSAs communicate between each other for sending email between different
    domains

