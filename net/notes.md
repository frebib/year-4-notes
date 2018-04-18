# Networks

# Basics
- Measure network performance with:
  - Throughput (bits per second)
  - Latency for bits to be sent (seconds)
    - Speed of light is a lower bound
  - Error rates (errors per bit)
    - Data loss is an error
- Can trade off error rate for latency
  - Voice can have high error rate, but needs low latency
  - OS images can have high latency, but needs no error rate

## Packet switching
- Originally had circuit switching
  - Telephone exchanges would swap wires around, so that there was a straight
    wire between callers
  - Inefficient, a wire would be hogged even if there was a gap of silence
- Divide data into packets (smaller segments of data)
- "Switch" packets across the network until the destination
  - "Switch" comes from train tracks - IMPORTANT: Memorise this for the exam

### Advantages
- Multiplexing in the *time* domain, rather than the *frequency* domain
  - i.e. instead of putting multiple signals into the same signal, we
    "interleave" the packets sent in time
- When no data is being sent, no data is being sent
- Statistical gain
  - If we pay for 10Mbps, we only use it some of the time
  - Therefore, we can share the 10Mbps between a group of people
  - Can lead to underprovisioning in peak times

### Problems
- Packets get lost, delayed, reordering
- Need to do a lot on the other side

## Virtual Circuits
- Works by:
  1. End point(s) tell network to establish a connection between then
  2. Network assigns this connection a token
  3. For the duration of the connection, all packets between the end points are
     with this token
  4. The network knows how to route according to this token, and all packets get
     sent down the same route
- Provides packet ordering, although it is not guaranteed

## Datagram Services
- Each packet contains complete addressing information
- Each packet considered separately by the network
- End points completely responsible for all problems caused by the network

## Virtual Circuits vs Datagram Services
- Bellheads vs Netheads
  - Bellheads like VCs because it allows them to shape traffic and control it
    better
  - Netheads like DSs because it means that telcos can't monitor/shape traffic

## Stacks
- Adds layer of abstraction
- We don't care about VCs/DSs, as long as our data gets through reliably/quickly

### DoD Model (TCP/IP Stack)
1. Application (HTTP, KIPA, etc.)
  - The highest level, where actual use of data occurs
2. Transport (TCP/UDP)
  - How packets are managed between the end points, reliable/unreliable
3. Internet (IP)
  - How routing between end points is managed, contains src/dest
4. Link (Ethernet)
  - Protocols for sending data down a wire
5. Physical
  - Like, kinda putting the data on the wire you know? Like actual electrons and
    data and stuff

### Planes
- Can think of these stacks as different planes
- Management plane
  - Where the data is used, requested, sent, etc (application layer)
- Control plane
  - Decides how packets are routed
- Data plane
  - Where data is actually sent

### Hardware
- Different hardware for different layers in the stack
- Switches understand the link layer, passing on packets between wires
- Routers understand the IP layer, so can look at IP packets and route between
  different networks
- Hosts understand transport and application layers, so we can actually do
  something you know?

# Lower Layers

## LANs and WANs
- Historically, very different in technology
- Historically, WANs were _very_ slow
- This meant WAN tech needed to be way more efficient than LAN tech

## Ethernet
- Originally, a single bus topology
- Early versions were 3Mbps, yellow ethernet wires are now 10Mbps
- Max length is 500m, can be amplified and regenerated to go 1500m max
- Format of ethernet frame
  - 7 byte preamble to let end points sync
  - 1 byte start of frame delimiter
  - 6 byte source address
  - 6 byte destination address
  - 4 byte VLAN tag
  - 2 byte type/length
  - 42-1500 bytes of payload
  - 4 byte CRC
  - 12 byte-time inter-packet gap
- Finding the end without a length
  - We know the CRC
  - We calculate the CRC continuously
  - Once we calculate the CRC of the data _and_ the CRC (which is at the end of
  the data), we know the data has finished

### Collisions
- Only one sender on the wire at any one time
- Senders must wait until no one else is sending on the line
- Detecting collision
  - As you transmit, if you listen back and don't see what you sent, then
  someone else is sending
- When a collision happens
  - "Jam" the network by sending a particular pattern
  - Whole network must know about the collision before the packet has finished
    being sent
    - TODO: Why?
  - This created the minimum packet size of 64 octets
    - TODO: Why?
- Recovery from collision
  - On the `n`th attempt to retransmit, chose a random number `k` from [0, 2^n]
    and delay `512k` bit periods before trying again
  - After 10 attempts, give up
  - Randoms don't need to be good quality here

### Problems
- Collisions increase non-linearly with load
- Latency for single packet is unpredictable

### 10Base5
- Maximum of 1500 bytes payload + 22 bytes of packet header
  - Much larger ends up slowing down nodes wanting to transfer small packets
- Minimum of 64 bytes
- Maximum diameter of 1500m
- 500m and 10Mbps gives name: 10Base5
  - Where did either of these numbers come from? God damn it Ian

### 10Base2
- Use thinner coax than 10Base5, but limits diameter to 200m

### 10BaseT
- Uses twisted pair instead of coax (hence T?)
- Originally cat3 cabling
  - TODO: What is cat3, and its realtion to coax/tp?

### Repeaters, Hubs, Bridges
- Repeaters amplify the signal on the wire, there are still collisions across the
  repeater
- Bridge receives, buffers and transmits frames, so collisions aren't propagated
- Ether hubs are repeaters, not bridges
- Imagine two networks A and B
  - Connected by repeater
    - Traffic inside of A can collide with traffic inside of B
  - Connected by dumb bridge
    - A does not collide with B, but can see each other's messages
      - TODO: How?
  -  Connected by filtering/learning bridge
    - A does not collide with B, and can not see each other's messages unless
      the bridge has not learnt what is local yet

### Speeds
- 10BaseT same speed as 10Base2, but more flexible
- 100BaseT faster, no collision solved
- 100BaseT had full duplex added + switching
- 1000BaseT, and 10GigE, 40GigE, soon 100GigE

### Cut Through Switches
- Can look at whole packet, check checksum
  - Introduces latency for checking
- Can look at header and just forward to right interface
  - Much less latency

### Random Early Drop
- When a buffer fills up, you start dropping packets when buffer is full
- Can instead drop packets with increasing probability as buffer fills
  - The sender sees dropping packets, and (hopefully) knows to slow down

## Ethernet Alternatives

### Token Rings
- Alternative to Ethernet
- Pass a "token" between nodes, if you hold the token you can transmit
- In theory, bounded latency: `num_nodes * max_packet_period ± fudge`
- Issues with token loss/creation
- Station failure

### Slotted Rings
- Empty data frames pass around the network, and can be filled by nodes
- Requires a minimum length of network
  - Resulting in long lengths of gable coiled under the floor

### Asynchronous Transfer Mode (ATM)
- Packets of 48 bytes
- Virtual circuit
- Used mostly in telco core networks (?)
- Not used now because of cheap ethernet

TODO: Some other techs mentioned here, but not in any detail - need to know?

# Internet Protocol (IP)
- Network layer that can
  - Have all transports run on it
  - Run on all available lower layers
- Unreliable, unsequenced, no checksum
- Has an address, and the network makes a best-effort attempt to deliver it
- IPv4 has 32 bit addresses
- Leftmost part defines network, rightmost defines node on that network
  - If address starts with a 0, first 8 bits identify the network (class A)
    - Gives us 128 networks, give to big companies/govs
  - 0 not used, 127 reserved for loopback
  - If address starts with 10, first 16 bits identify the network (class B)
  - If address starts with 110, first 24 bits identify the network (class C)
  - Rest used for multicast, and experimental things
- Wasteful, but made it easy for routers
  - Routers look at address, is it local? If so, send directly
  - Is first bit 0? If so, look up first 8 bits in "next hops"
    - These are IPs that are closer to the destination
  - Otherwise, look up the address in a more complicated structure
  - Otherwise, use the default route
- Netmasks
  - Netmask for class A is /8
    - `/8` → `11111111.0000...`
    - `11111111.0000... & addr` → net address

## RFC1918
- Private addresses
- 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 are for private use
- Should not be sent outside of private domains
  - Often routers filter them out, but not always

## IPv6
- 128 bit addresses
- But in reality, mainly 64 bit addresses
  - Even phones will get a /64 address
- `::` means as many zeros as fit here
- `::/128` uninitialised
- `::1/128` loopback
- `::ffff/96` IPv4 mapping (e.g. `::ffff:1.2.3.4`)
- `fc00::/7` private address space
- `fe80::/8` link local (?)
- `2001:db8::/32` documentation (?)
- `2000::/3` single block for normal use (?)

## IP on Ethernet
- Need to know MAC address to send to
- Uses Address Resolution Protocol (ARP)
  - Ask broadcast "who owns this IP?"

## Hop Counts
- Each IP packet has a Time To Live (TTL)
- Decremented each time packet is processed (or held for a second)
- When it hits 0, packet discarded and error sent back to sender
- IPv6 doesn't have this, relies on lower-level constructs

# Address Allocation

## Ethernet/MAC Address
- Unique to a machine
- 48 bits/6 bytes
- 3 bytes for manufacturer
- 3 bytes for device

## Getting IP Numbers
- Small allocations come from ISP, still belong to them
- Can get allocations from regional registries, hard to get

### Getting Local IP Numbers
- Static allocation
  - Node given an IP address in a config
  - Every time node boots, uses that IP
  - Can cause conflicts, or even be outside of IP range for that network
  - Used for routers etc. that need to be up quickly after network goes down
- bootp
  - Device broadcasts MAC
  - bootp server sends back IP number
    - And stuff like DNS server, default router, etc.
  - No means to reclaim addresses that aren't used anymore

## Dynamic Host Configuration Protocol (DHCP)
- You "lease" temp IP addresses for a set duration
- Handles static IP addresses
- Setup steps:
  1. `DHCPDISCOVER`: Node broadcasts request for any IP address, sends its MAC
     address in the packet
  2. `DHCPOFFER`: DHCP server reserves an IP address, and replies with an
     offer which has a lease time
  3. `DHCPREQUEST`: Node chooses among offers (if there are multiple DHCP
     servers) and broadcasts reply with the chosen IP address
  4. `DHCPACK`: The server sees the request and acknowledges that it has been
     processed. Other servers can see that their offer has been declined
- Can send a request to known DHCP server, asking to renew the lease
  - Conventionally done once half the lease has passed
- Can use static IPs, always handing the same MACs the same IPs
- Some DHCP servers will update DNS servers with the IP address bindings
- DHCP redundancy
  - Two DHCP servers, disjoint pools, let client select
  - Backup DHCP server, lagging behind by a second, in case first goes down
  - Complex failover protocols, all DHCPs make same request (rare)

### DHCP with Multiple Networks
- DHCP server on each network
  - Now you have multiple points of failure
- DHCP server attached to all networks
  - Doesn't scale well
  - Bad for security, as DHCP server bypasses firewalls
- Relaying
  - Relay agent on each network, usually tied into router
  - Relay agent hears broadcast packet, sends it on to known DHCP server
  - Server sends back to relay, relay sends back to requester

### DoS DHCP
- Send loads of requests, and the DHCP servers will run out of IPs quick

## IPv6 Allocation
- DHCPv6, with all the same problems
- IPv6 routers will periodically broadcast their info, including subnetmask
- So we can use Stateless Address Auto Configuration (SLAAC)
  - Take /64 of subnet, and use our MAC and other stuff to put into the address
  - Collisions unlikely
  - Difficult to do DNS with just IPv6
    - If router ad has `M` flag set, network is managed
      - Clients can't use SLAAC, must use DHCPv6
    - If router ad has `O` flag set..
      - Use SLAAC, but go to DHCPv6 server for other data (like DNS)
      - DHCPv6 server doesn't need to manage leases, essentially static
  - Privacy issue
    - Your MAC address as available to everyone else
    - Meaning 3rd parties can track your devices across networks

# TCP/UDP
- TCP is reliable
  - Arrives in-order
  - Congestion control
  - Connection setup
- UDP is unreliable
  - Unordered, basic extension of IP

## UDP
- Socket identified by two-tuple: (destination IP, destination port)
- Packets directed to same port, but from different IPs, will be sent to the
  same socket
- Connectionless, no handshaking, all packets handled independently of each
  other
- Header:
  - Source port #
  - Destination port #
  - Length of packet, incl. header
  - Checksum
  - Payload
- TODO: Do we need to know checksums?

## TCP
- Need to ACK packets
- If we get no ACK, resend after some period
- Have sequence numbers in order to detect duplicates
- However, waiting for ACKs is long
- Therefore, we pipeline packets
  - Sender can have `n` unACK'd packets at one time
  - Receiver sends cumulative ACK, i.e. ACK up to packet #
  - So you have:
    - ACK'd packets
    - Send, unACK'd packets
    - In buffer, unsent
    - Not in buffer yet
- Selective repeat
  - If we have packet #1, #2, and #4
  - We ACK #2, #3, and then #3 again to say that's where we got up to
    - We ACK the next number we're expecting
- Header
  - Source port #
  - Destination port #
  - Sequence number
  - ACK number
  - Flags
  - Receive window
  - Checksum
  - Urgent data pointer
  - Options
  - Data

### Flow Control
- Use the receive window section in header
- This is the amount of data that can be unACK'd

### 3-way Handshake
- Client chooses seq# `x`, send `(SYN, seq=x)`
- Server chooses seq# `y`, send `(SYN+ACK, seq=y, ack=x+1)`
- Client acknowledges, send `(ACK, seq=x+1, ack=y+1)`

### Close Connection
- Send TCP packet with `FIN` flag
- Reply with `FIN+ACK`
- Reply with `ACK`

### Window Scaling
- Receive window limited to 64k
- Very low limit
- To solve this, there's a scaling value
- Increases window size to 2^14

### PAWS
- 4GB worth of sequence numbers, so if you want to send more than 4GB there's
  no way to distinguish between new and old packets
- We add a timestamp to the headers in order to distinguish
- This timestamp can also be used to measure round-trip time

### Slow Start
- LAN is faster than WAN mainly
- So we advertise large rec window, but then the router has to churn it out
  slowly
- This could lead to router running out of memory
- So what we do, is send one packet, then two, and then increase some amount
  every time we get an ACK (usually exponentially), until we hit rec window

# Network APIs

## Reading/Writing Files in Unix
- `fd = open(path, mode);`: Open a file that indexes into a table of open files
- `bytes_read = read(fd, buffer, size);`
- `bytes_written = write(fd, buffer, size);`
- `err = close(fd);`
- `err = ioctl(fd, op, argptr);`: perform operation on underlying physical
  device
- `err = fcntl(fd, op, argptr);`: perform operation to file descriptor

## Reading/Writing Sockets in Unix
- Originally done as in files, but `ls`ing the `/net` directory wouldn't work
- Now we have the socket API:
  - `socket()` syscall creates our end of the connection (returns `fd`)
    - Takes domain `{PF_UNIX, PF_INET, PF_INET6}` for stuff like unix sockets,
      IPv4, IPv6
    - Takes type `{SOCK_STREAM, SOCK_DGRAM, SOCK_RAW}` for TCP, UDP, raw
      packets.
  - `bind()` syscall associates local end with addressing information (i.e.
    port)
    - Takes an address struct `sockaddr_in, sockaddr_in6`
  - `connect()` syscall links socket to another node
  - `send(), sendto(), recv(), recvfrom()` syscalls are `read(), write()`
    analogues
  - `shutdown()` syscall is the same as `close()`
- Must convert to big endian on the wire
  - `htons(), htonl(), ntohs(), ntohl()` for converting long/short values
    to/from network endienness
- On the server:
  - Call `listen()` instead of `bind()`
  - This creates a *new* socket to communicate with the connectee, and leaves
    the old socket to listen for new connections

# HTTP and Friends

## FTP
- Send a file name, receive a file
- Many variants
  - FTP, oldest, ugliest
  - kermit
  - uucp
- Mainly killed by HTTP

## Hypertext Transport Protocol (HTTP)
- Originally supposed to deal with downloading HTML with support for hyperlinks
- Can request with `HTTP GET`
- Very easy to implement
- Very flexible
- Decouples names from things

### Requests
- Send `GET /index.html HTTP/1.1`
  - Tells us what operation, what resource to get, and the HTTP version
- Can have several attributes, e.g. `User-Agent: ...`
- Followed by blank line
  - Liens terminated with `\r\n`

### Responses
- Reply `HTTP/1.1 200 OK`
  - Code saying response, and string describing response
- Can also have several attributes, e.g. `Date: ...`

### Other Operations
- `PUT`
  - File upload
- `DELETE`
  - Delete a resource. Not used for actual files, but used for RESTful APIs

## Cookies
- Store a string on a HTTP client
- Can have lifetimes
- Often abused in usage, and therefore abused for security holes

## Caching
- Often cache HTTP results in the HTTP client
- But perhaps better to cache on HTTP server

# Other Transports

## Real-time Transport Protocol
- Used to transport voice and video in some applications
- Doesn't do much more than UDP
- Problems for voice/audio
  - Consistent timing
  - Drop, or catch up?
  - Buffering?
- Apparently latency over 35ms is problematic for voice
- Each packet contains sequence number and timestamp
- No ACKs

## Multipath TCP
- Allows multiple paths to be used by one TCP connection
- e.g. Wifi and 4G together
- Performance + fail safe
- Very new

# Network Address Translation (NAT)
- Extends scarce IP numbers
- Also provides some security, hiding local machines from the internet
- Breaks "end to end principle"
- Outbound NAT
  - Connection is modified so that multiple IPs are mapped to subset of ports of
    smaller amount of IPs
- Inbound NAT
  - Reverse of outbound, but keeps ports inbound the same
- This works because TCP connections are distinguished by `(src ip, dst ip, srt
  port, dst port)`
- Usually only use one external IP, unless you need >65535 connections

## Problems
- Hard to log
- Hard to authenticate users behind same NAT
- TODO: Clock offsets?
- Delays IoT
  - Need universal connectivity

## IPv6
- No NAT
- Proposals of IPv6 NAT for security reasons
- NAT is kinda a stateful firewall
- Regarding NAT as an actual firewall is a problem, because it is not designed
  to be

