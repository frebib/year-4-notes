# Networks

# Topics List
- [x] Transmission (all at a very high level only)
  - [x] ATM
  - [x] WDM
  - [x] SDH
- [x] Ethernet
  - [x] Switching
  - [x] Collisions
  - [x] Bridging
  - [x] Broadcasting
  - [x] VLANs
  - [x] Link aggregation
- [x] IP
  - [x] Addressing
  - [x] IPv4 and v6 subnets and prefixes
  - [x] Routing
  - [x] Routing protocols
    - [x] RIP
    - [x] OSPF
    - [x] Convergence properties
  - [x] NAT
- [x] UDP
  - [x] Applications
  - [x] Advantages and disadvantages
- [x] TCP
  - [x] Applications
  - [x] Advantages and disadvantages
  - [x] Mechanisms and operation
    - [x] Three-way handshake
    - [x] Finish handshake
  - [x] Sequence numbers
  - [x] Receive windows
    - [x] Go-Back-N
    - [x] Selective repeat
  - [x] Slow start
  - [x] Window scaling
  - [x] PAWS
  - [x] Timestamping
  - [x] Multipathing
- [x] DNS
  - [x] Concepts
  - [x] Resource records
  - [x] RR sets
  - [x] Basic operation
  - [x] Recursive and authoritative servers
  - [x] Caching
- [x] Higher layer protocols (Basic operation of)
  - [x] HTTP
  - [x] FTP
  - [x] SMTP

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
    being sent, so they don't think the packet is valid
  - This created the minimum packet size of 64 bytes
- Recovery from collision
  - On the `n`th attempt to retransmit, chose a random number `k` from [0, 2ⁿ]
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
- Repeaters amplify the signal on the wire, there are still collisions across
  the repeater
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

### Wave Division Multiplexing (WDM)
- Use different colour light ot transmit multiple streams down a single fibre
- Dense/Coarse WDM (DWDM/CWDM)
  - Coarse: 20nm difference between adjacent channels
  - Dense: 0.8/0.4/0.2nm difference between adjacent channels
- Can go up to 10Tbps+
- Telcos do ethernet straight over WDM
- Long range

### Synchronous Digital Hierarchy (SDH)
- Deals in "trails" of data (which I think is just a stream of data...?)
- Trails are 2Mbps+
- Multiplexes these trails into STM1/4/16/64 which has speeds of
  155Mbps/622Mbps/2.4Gbps/10Gbps
- Extract and insert individual 2Mbps trails into the total stream
- Still mostly used for long-haul internet traffic

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
- `FIN/ACK/FIN/ACK`
- `FIN-ACK/FIN-ACK`
- `FIN/FIN-ACK/ACK`

### Window Scaling
- Receive window limited to 64k (16 bits)
- Very low limit
- To solve this, there's a scaling value, 4 bits, max 14, default 7
- `new_window_size = window_size << window_scale`
- Increases window size to `2^(16+14) = 2^30`

### PAWS
- 4GB worth of sequence numbers, so if you want to send more than 4GB there's
  no way to distinguish between new and old packets
- We add a millisecond timestamp to the headers in order to distinguish
- This timestamp can also be used to measure round-trip time
- Also allows us to reliably measure round-trip-time

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
- Say `MP_CAPABLE` in initial connections
- Say `MP_JOIN` over different interface(s) with MAC to join initial connection

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

# Multiple Interfaces
- Typical desktop only has one interface
- Typical server has several interfaces (called multihomed server)
  - For performance
  - For keeping networks separate without buying multiple routers

## Programming
- Can bind to `INADDR_ANY` to listen on all interfaces
- Source address is set based on the packet that initiates the request

## Connecting to Multihomed Servers
- Try each interface in turn (not in parallel)
- Cache the live interface
- Naive clients will assume one interface
  - Then we handle which interface is given through DNS hacks
  - Use round-robin behaviour (iterate through interfaces)
- Smarter clients will try all interfaces in order returned by `gethostname`
- Even smarter clients will use `getaddrinfo`
  - Returns IPv4/6 addresses

## UDP
- If you send a request to an IP, you should receive response from that IP
- One technique:
  - Listen on `0.0.0.0`, look at destination address on each packet received
  - Copy destination address into source address of response
- Another technique:
  - Listen on each interface individually
  - Effectively have multiple copies of the application
  - More flexible, but need to iterate over interfaces and update when they
    change
- You can set sender to any IP on some kernels, but kernel will still route
  through interface it believes to be closest to destination

## TCP
- Kernel will handle replies having the same source address
- Can just listen on `0.0.0.0`

## Link-Agg
- Link aggregation
- Multiple interfaces, one IP number
- Fast failover if an interface goes down
- Efficient multiplexing and load spreading
- However, only goes as far as the nearest switch

## VLANs
- Ethernet frames have an optional `tag` field (0-1023, or 0-4095)
- Differentiate between different "networks" going over the same wire
- OS sees them as two separate networks
- Untagged ports
  - Don't need to understand VLANs

## Link-Agg + VLANs
- Deliver two+ networks over two+ cables
- Full load balancing
- Full failover

# Domain Name Service (DNS)
- Maps names to IP numbers (v4, v6) and vice versa
- Locates resources
- Once you own a domain name
  - Create resource records for the domain
  - Delegate portions of the namespace to other nameservers
  - Zone: group of resource records served from one nameserver
- Lots of caching involved

## Resource Records
- Map a name to some data + some book keeping
- `A` records contain IPv4 addresses
- `AAAA` records contain IPv6 addresses
- `PTR` records contain IP addresses to domain names
- `MX` records contain mail exchangers
- `NS` records contain nameservers
- `CNAME` records contain aliases
- `SOA` records contain authority records
- `TXT` records contain random text information
- Each record has a class, but is always set to internet (`IN`)
- Represented as (name, TTL, class, type, data)
  - `foo.domain.com` represented as `[3]foo[6]domain[3]com[0]` where `[3]` is
    the byte value for 3 (`0b00000011`)

## Time to Live (TTL)
- In seconds
- You can cache a RR for this long

## Zones
Example:
- .com
  - xyz.com
  - abc.com
    - eu.abc.com
      - sales.eu.abc.com
    - asia.abc.com
      - east.asia.abc.com
      - west.asia.abc.com
Can segment the tree up however you want to create zones

## Components
- Clients
  - Make DNS queries to recursive servers
- Recursive/caching servers
  - Will give an answer, but sometimes inauthoritative
- Authoritative/iterative server
  - Will give authoritative answers about zones they are configured to know
    about

## Header
- ID, 16 bit: identifier for question and answer
- QR, 1 bit: 0 is query, 1 is response
- OP, 5 bits: 0 is QUERY, 1 is IQUERY, 2 is STATUS, 4 is NOTIFY (master
  informing slave that zone has changed), 5 is update (dynamic DNS)
- Some flags:
  - AA: Authoritative answer, or answer is fresh from authoritative server
  - TC: Truncation, if 1, more than 512 bytes of response, so client should open
    TCP connection and get information
  - RD: Recursion desired, please answer this question in its entirety (TODO: ?)
  - RA: Recursion available
  - Various error codes

## Label Compression
- Labels are max 63 bytes, so largest value for length field is `0b00111111`
- Length fields starting 11 are special:
  - If starts with 11, the next 6 bits + 1 byte = 14 bits are special
- TODO: How does this work?

## Name Resolution
- Recursive nameserver will ask for `dom.ain.com`, and either get a reply for:
  - `com`
  - `ain.com`
  - `dom.ain.com`
- Then can ask the next server down until someone answers with an A record
- Multiple servers, meaning load balancing and redundancy

# Other Protocols

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
  - Client receives data to `:P`

## Simple Mail Transfer Protocol (SMTP)
- Sending email
- Extensions for auth, encryption, etc.
- Mail user agents (MUAs) talk to mail transport/submission agents (MTAs/MSAs)

### Message Format
```
HELO
MAIL FROM you@gmail.com
RCPT TO them@gmail.com
DATA some message
.
QUIT
```

## POP3
- Downloading email
- Connect, count messages, download
- Assumes user has one device
- Always prefer IMAP

## IMAP
- Downloading email
- Remote searching
- Can provide POP3 interface

## Secure Shell (SSH)
- Encrypted transport
- Suited for short messages, e.g. character-by-character typing
- Can use password auth, or public key

## NFS
- Remote filesystem for thin clients

# Routing Protocols
- Isn't handled by the network, we are responsible for the next hop
- Can't dictate beyond the next hope
- Loops can happen because of this

## Static Routing
- Say that "this network goes to this router, this network goes to this router,
  other networks go to this router"
- No resilience

## Interior vs. Exterior Routing
- Interior is when all equipment is managed by one entity
  - Small networks, max 100s
  - More trust between nodes
- Exterior is when equipment is managed by multiple entities
  - Needs to be able to handle the entire internet
  - No central authority

## Objectives
- Find the best path
- Find the best path _now_ if it changes regularly, which it will with large
  networks
- Find the minimal spanning tree
- Metrics
  - When building a minimal spanning tree, need to evaluate edges
  - This is difficult: must include bandwidth, latency, reliability, etc.

## Internal Routing

### Distance Vector
- Simple early algorithm
- TODO: What is this?!

### Routing Information Protocol (RIP)
- Each connected network is one hop away
- Each node broadcasts all the networks it knows how to reach, along with their
  hop count
- Metrics are from 0-16
  - 0 is us
  - 16 is unreachable
  - Sets maximum diameter of network
- Limits ability to use metrics to indicate slow/unreliable links
- Problem:
  - A is next to B
  - A tells C that it is next to B
  - C thinks it is 2 away from B
  - A→B link goes down
  - C tells A it is two away from B
  - Link distances will get bigger and bigger until 16, then removed
- TTLs in packets are large, so packets going through loops could take a while
- Solution 1: flash update
  - Usually send packets every 30s
  - Now also send packets when things change
  - Same progression, but a lot quicker
- Solution 2: split horizon
  - Keep track of which interface advertises which networks
  - Only send updates from one interface to all the other interfaces
- Solution 3: poison reverse
  - When a link breaks, send metric 16 update
- Good for small networks, starts to fail for large
  - Slow propgations of topology

#### RIPv2
- Uses subnetmasks instead of classful networks like RIP
- Added security with hash, sequence numbers
- Not used
- Also have RIPng, RIPv2 with IPv6

### Open Shortest Path First (OSPF)
- Link state protocol
- Devices on a subnet exchange `HELLO` packets to learn about local neighbours
- Elect a designated router + backup (DR + BDR)
  - From devices that have multiple interfaces
- DR and BDR exchange link state advertisements (LSA) with neighbouring routers
- When LSA information changes, recompute a set of routing tables
- DR + BDR announce a complete set of non-local routes to other systems on the
  local network

#### Areas
- Network will have a small group of highly connected core routers, networks
  connected to one of the core routers
- One area's router will advertise the area

#### Pros and Cons
- Pros:
  - Converges within a few seconds of topology change, DR/BDR routers exchange
    LSAs on demand
- Cons:
  - CPU intensive, not a problem any more
  - Complex to configure
  - Shortage of open source implementations

### Load Balancing
- RIP can balance across networks with same metrics
- OSPF can do the same for metrics that are close enough to each other

## External Routing
- Autonomous systems (AS)
  - Large networks on the internet
  - Each routable network has exactly one AS number
- You get ASNs from ISPs (TODO: ?)
- Assumption that everyone in an AS knows how to reach everyone inside that AS

### Border Gateway Protocol (BGP)
- Routers peer over TCP
- Updates are incremental
- The route to a network reached by another router has a cost equal to the one
  advertised by the router, plus the cost of getting to that router
- Each route also contains the vector containing an ordered list of all ASs that
  the route passed through

