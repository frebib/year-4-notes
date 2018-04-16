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

