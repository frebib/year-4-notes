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

