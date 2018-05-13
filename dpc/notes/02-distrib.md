# Distributed and Parallel Computing - Distributed Computing

# Introduction
- Distributed computing means computing on multiple nodes/processes
- Each node as a unique ID
- Nodes are connected via channels (i.e. edges)
- Nodes do not share memory or a global clock
- Nodes are either connected or not connected
- Networks are strongly connected (i.e. there is a path between any two nodes)
- Networks don't necessarily have to be complete (i.e. edge between every
  pair of nodes)
- Channels may be directed or undirected
  - TODO: How does this relate to "nodes are either connected/not connected"?
- Communication is passing messages over channels
- Channels are not necessarily FIFO
- Communication is asynchronous

## Parameters of the Network
- `N` number of nodes
- `E` number of edges
- `D` diameter of the network, i.e. the longest "shortest path" between any
  two nodes

## Failures
- Failure rate (FR): Number of failures per unit time
- Mean time before failure (MTBF): `1/FR`
- e.g.
  - 1000 nodes, all critical
  - MTBF of each node is 10,000
  - `FRₙ = 1/MTBF`
  - `FRₙ = 1/10,000`
  - `FRₛ = sum(FRₙ for n in nodes)`
  - `FRₛ = 1,000 * (1/10,000)`
  - `FRₛ = 1/10`
  - `MTBFₛ = 1/(1/10)`
  - `MTBFₛ = 10`

## Spanning Trees
- Spanning tree:
  - Contains all the nodes of the network
  - Edges are a subset of the network's edges
  - No cycles
  - Undirected
- Tree edges: edges in the spanning tree
- Frond edges: edges in the network but not in the spanning tree
- Sink tree: tree made by taking all edges of a spanning tree, and making them
  directed so that all paths end up at some chosen root node

### Usage
- We want to send a message to the whole network
- If we send to neighbours recursively, it doesn't terminate
- If we send to the spanning tree root, and then follow the reverse of the sink
  tree (as in the edges are reversed), then every node only sees the message
  once

## Transition Systems
- The behaviour of a distributed algorithm is given by a transition system:
  - Set of configurations: `(λ, δ) ∈ C`
    - Global state of the algorithm
    - `C` is the set of all possible configurations of an algorithm
  - Binary transition relation on `C: λ → δ`
    - Changes the global state from one configuration to another
  - A set of initial configurations: `I`
- A configuration is terminal if there are no transitions out of the
  configuration
- An execution is a sequence of states in `C`, beginning with an element in `I`,
  and can either be infinite or ending in a terminal configuration
- A configuration is reachable if there is an execution that contains it

### States and Events
- Configuration consists of
  - The set of local states of each node
  - The messages in transit between the nodes
- Transitions are connected with events
  - Internal: an action that modifies the internal state of a process
  - Send: A message is sent from a process
  - Receive: A message is received by a process
- Initiator: the process where the first event is an internal, or a send event
- Centralised: only one initiator
- Decentralised: multiple initiators

## Assertions
- Safety property
  - Must be true on every reachable configuration
- Liveness property
  - Must be a reachable configuration with this property, from every
    configuration

## Orders
- Total order
  - `a ≤ a` reflexivity
  - `a ≤ b && b ≤ a → a = b` antisymmetry
  - `a ≤ b && b ≤ c → a ≤ c` transitivity
  - `a ≤ b || b ≤ a` totality
- Partial order
  - `a ≤ a` reflexivity
  - `a ≤ b && b ≤ a → a = b` antisymmetry
  - `a ≤ b && b ≤ c → a ≤ c` transitivity
  -  No totality
- Causal order
  - `a ≺ b` iff `a` must occur before `b` in any execution
  - If `a` is send, and `b` is receive, then `a ≺ b`
  - `a ≺ b && b ≺ c → a ≺ c`

## Computations
- Executions are too specific, different orders means different executions but
  same work is done
- Instead, we talk about "computations", a set of executions equivalent up to
  permutations of concurrent events

# Local Clocks
- Maps to a partially ordered set (i.e. integers) such that
  - `a ≺ b ⇒ C(a) ≺ C(b)`
- Requires each process maintains a record of:
  - Its local logical clock, measuring the process's own progress
  - Its global logical clock, measuring its perception of global time

## Lamport's Clock
- Notated as `LC(event)`
- Tracks local and global logical clocks in one variable
- Let `a` be an event, and `k` be the clock value of the previous event
  - If `a` is internal or send, `LC(a) = k + 1`
  - If `a` is receive, and `b` is the send event of `a`, `LC(a) = max(k, b + 1)`
- Consistent with causality, but not strongly consistent
  - i.e. `a ≺ b ⇒ LC(a) ≺ LC(b)` but _not_ `LC(a) ≺ LC(b) ⇒ a ≺ b`

## Vector Clock
- Each process keeps a vector, the same length as the number of process
- `vᵢ[i]` is the local logical clock
- `vᵢ[j]` where `i ≠ j`, is process `i`'s most recent knowledge of process `j`'s
  logical clock
- Initialise all of `vᵢ` to 0
  - If `a` is internal or send
    - `vᵢ[i] += 1`
  - If `a` is receive, and `m` is the vector clock sent with `a`
    - `vᵢ = max(vᵢ, m); vᵢ[i] += 1`
- Ordering
  - `u = v ↔ ∀i. u[i] = v[i]`
  - `u ≤ v ↔ ∀i. u[i] ≤ v[i]`
  - `u < v ↔ u ≤ v && ∃i. u[i] < v[i]`
  - `u || v ↔ u !≤ v && v !≤ u`
- Strongly consistent!

## Mutual Exclusion
- Centralised
  - Works
  - Easy to implement
  - Fair (in order of request)
  - No starvation (no node waits forever)
  - Only 3 messages per use of resource (ask, grant, release)
  - However, single point of failure, and a big bottleneck
- Decentralised (Ricart-Agrawala)
  - To request a resource, send message to all process requesting resource
  - When process receives message:
    - If not using and doesn't want
      - Send OK back to sender
    - If has access
      - No reply, but queues the request
    - Wants the resource but doesn't have it
      - Compares logical clock value of requester
        - If requester has lower, send OK message
        - If requester has higher, queue message and send nothing
  - When sending a message, wait for an OK from everyone else, once this happens
    it can access the resource
  - When done with the resource, check queue and send OK to all of them
- Advantages: works, fair, no starvation
- Disadvantages: `2(n - 1)` messages, `N` points of failure, every node needs to
  keep track of every other node in the system

# Snapshots
- Allows saving program state so we can resume later
- Allows returning to previous state if things break
- With distributed systems, can't do this because there's no global clock
- Messages could be on the fly, difficult to record this state
- Recording local snapshots must be coordinated correctly to ensure a consistent
  global snapshot
- If each process takes a local snapshot:
  - An event is pre-snapshot if it occurs in a process before the local snapshot
  - Otherwise it is post-snapshot
- A snapshot is consistent if
  - When `a` is pre-snapshot, `x ≺ a` implies `x` is pre-snapshot
  - A message is included in channel state if its sending is pre-snapshot and
    its receiving is post-snapshot

## Chandy-Lamport Algorithm
- Applies to FIFO channel systems only
- Send control messages called markers along channels to separate pre- and
  post-snapshot events and trigger local snapshots
- Initiator takes local snapshot and sends marker through all outgoing channels
- When process `pₘ` receives marker along channel `cₙₘ`
  - If `pₘ` has not yet saved state
    - `pₘ` saves local state
    - `pₘ` sets `cₙₘ` state to `{}`
    - `pₘ` sends marker through to all outgoing channels
  - Else
    - `pₘ` records state of `cₘₙ` as set of all basic messages received after it
      has saved its local state, and before it received the marker message from
      `pₙ`

### Correctness
- If `a ≺ b` and `b` is pre-snapshot then `a` is pre-snapshot
- If `a` is send and `b` is receive of the same message in processes `p` and `q`
  - `b` is pre-snapshot → `q` has not received a marker when `b` occurs
  - Since channels are FIFO, `p` has not sent a marker when `a` occurs
  - Hence, `a` is pre-snapshot
  - This chain of causality travels through to all events
- Message `m` between `p, q` is in channel state `Cpq` iff send of `m` at `p` is
  pre-snapshot, and receive at `q` is post-snapshot
  - Forward direction
    - Assume `m ∈ Cpq`
    - Since `q` has saved `m`, it must occur after we have the control message
      from another channel (or `q` is the initiator), so receive of `m` is
      post-snapshot
    - Since `q` has saved `m`, it must occur before `q` has the control message
      from `p`, so the send of `m` is before `p` has the control message, so
      send of `m` is pre-snapshot
  - Backwards direction
    - Assume send of `m` is pre-snapshot and receive of `m` is post-snapshot
    - Send of `m` pre-snapshot implies `p` saves state after sending `m`, hence
      control message sent down `Cpq` after `m`
      - And received in same order due to FIFO
    - Receive of `m` post-snapshot implies that `q` has received the control
      message already from a different node (or `q` is initiator)
    - Since `q` has saved local state but hasn't received control message from
      `p`, it saves `m` in `Cpq`

## Lai-Yang-Mattern Algorithm
- Works on non-FIFO channels
- Rather than having separate marker messages, attach boolean flag to basic
  messages
  - Typically described as white/red
- Lai-Yang algorithm didn't need control messages, but required keeping all
  message history
- Lai-Yang-Mattern algorithm uses control messages with logical clocks

### Algorithm
- Every process initialised to white
- When a process saves its local state:
  - Turn red
  - Send control message on all outgoing channels to say how many white messages
    it has sent down that channel
- Every basic message is the same colour as the process that sends it
- White process can save local state at any time
  - But must save it no later than on receiving a red message, and before
    processing that message
- When receiving the control message:
  - Save local state if it hasn't already
  - Process knows how many white messages it has received currently on each
    input channel
  - Process knows how many white messages it needs to receive from the control
    message
  - Waits for white messages
  - Each process channel computes channel state as the set of white messages it
    receives after saving its local state

### Correctness
- `a ≺ b ^ pre(b) → pre(a)`
  - `a, b ∈ q` then trivially true
  - `a := send(m), b := recv(m)`
    - `pre(b) → white(b)`
    - `white(b) → white(a)`
    - `white(a) → pre(a)`
- `m ∈ Cpq → pre(send(m)) ^ post(send(m))`
  - `m ∈ Cpq → white(send(m)) → pre(send(m))` because of rules
  - `m ∈ Cpq → control(q) ≺ recv(m)`
  - `control(q) ≺ recv(m) → red(recv(m)) → post(recv(m))`
- `pre(send(m)) ^ post(send(m)) → m ∈ Cpq`
  - `pre(send(m)) → white(send(m))`
  - `post(recv(m)) → control(q) ≺ recv(m)`
  - `control(q) ≺ recv(m) → m ∈ Cpq`

### Multiple Snapshots
- Instead of red/white, use counter `k`
- On first snapshot, `k = 0` is white, `k = 1` is red
- On second snapshot, `k = 1` is white, `k = 2` is red
- If two nodes start snapshot concurrently, they will both increment and the
  snapshot will be the same

# Wave Algorithms
- Sends request through network to gather information
- Can be used for: termination detection, routing, leader election, transaction
  commit voting
- A wave algorithm needs three conditions:
  - Finite
  - One or more decide events
  - `∀ a ∈ D, p ∈ P. ∃ b ∈ p.E. b ≺ a` where
    - `D` is the decide events
    - `P` is the processes
    - `p.E` is the events in a process `p`
    - Means every process must participate in each decide event

## Traversal Algorithm
- An initiator sends a token to visit each process
- The token may collect/distribute information on the way
- The token returns to the initiator
- The initiator makes the decision

### Tarry's Algorithm
- Traversal algorithm for undirected networks
- Two main rules:
  - A process never forwards the token through the same channel twice
  - A process only forwards the token to its parent when there is no other
    option
    - The parent is the first person to send the token to it
- Performance
  - Number of messages: `2E`
  - Time to complete: `2E`
- Depth first search
  - Token is forward to a process that has not yet held the token, in preference
    to one that has
  - Means that frond edges will only connect ancestors/descendants
  - We can make Tarry's algorithm DFS by adding a rule:
    - If rules 1&2 allow it, send the token down the same channel as soon as you
      receive it
  - Advantages
    - Let the token carry information of all processes that carried it
    - Avoid sending this information down frond edges (meaning that extra memory
      would be required)
    - Messages only travel down spanning tree edges, so `2E → 2N - 2`

## Echo Algorithm
- Wave, but not traversal algorithm
- Centralised
- Undirected networks
- Outline:
  1. Initiator sends message to all neighbours
  2. When non-initiator receives message:
    - Makes the sender its parent
    - Sends message to all neighbours except its parent
  3. When non-initiator received messages from all neighbours:
    - Send message to parent
  4. When initiator received all messages from neighbours, the algorithm
     terminates
- This builds a spanning tree
- Number of messages: `2E`
- Worst case time to complete: `2N - 2`

# Deadlocks
- Process stuck in infinite wait
- Communication deadlock
  - Cycle of processes, each waiting for the next to send a message
- Resource deadlock
  - Cycle of processes waiting for a resource held by the next process
  - Different resources

## Dealing with Deadlocks
- Make deadlocks impossible by designing protocols with this in mind
- Only obtain resource if global state ensures it is safe
- Detect deadlocks, and break the chain when they occur

### Waits-For Graph (WFG)
- Directed graph
- Nodes are processes
- Edge from `p` to `q` means that `p` is waiting for `q` to respond
- If there's an cycle in the WFG, then a deadlock has happened (in simple
  models)
- Single-resource model
  - Process can only have one outstanding request for a resource
  - Cycle in WFG means deadlock
  - Simplest model
- AND model
  - Process can request multiple simultaneously, and all resources needed to
    unblock
  - Cycle in WFG means deadlock
- OR model
  - Process can request multiple simultaneously, and only one resource needed to
    unblock
  - Cycle in WFG does not mean deadlock
  - Knot in WFG means deadlock
    - A knot is a set of vertices such that every vertex `u` reachable from a
      not vertex `v` can also reach `v`
- AND-OR model
  - Generalises AND model and OR model
  - No simple graph structure for detecting deadlocks (TODO: why do we use it
    then?!)
- p-out-of-q model
  - Equivalent to AND-OR model
  - Process requests `p` resources and `q` are needed to unblock
- Unrestricted model
- Problems
  - We need to maintain the WFG
  - We need to find cycles/knots in WFG
  - A deadlock detection algorithm must guarantee:
    1. Progress
      - All existing deadlocks must be found in finite time
    2. Safety
      - Must not report deadlocks that do not exist

# WFGs Continued
- There is a node `v` for each process in the network
- Nodes can be active or blocked
- Active node can make n-out-of-m requests of other nodes and then becomes
  blocked, or grant requests to other nodes
- A blocked node can not make or grant requests, but can become active if a
  number of its requests are granted
- When a blocked node gets n-out-of-m requests granted, it purges the remaining
  `m - n` requests
- When node `a` gets a request from node `b`, there is a dependency for `b→a`
- When `a` grants `b`'s request, the dependency moves to `a→b` until `b` releases
  the resource

## Distributed WFG
- Do not wish to centralise
- Each node retains information about local part of WFG
- Distributed deadlock detection algorithm invoked by initiator
- Each node `u` has a set of variables:
  - `OUTᵤ`: Set of nodes that `u` has sent ungranted requests to
  - `INᵤ`: Set of nodes that `u` has received requests from
  - `nᵤ`: Number of nodes that `u` needs to receive until it becomes unblocked
    - `0 ≤ nᵤ ≤ |OUTᵤ|`
    - `nᵤ = 0 ⇒ OUTᵤ = {}`

## Bracha-Toueg Deadlock Detection Algorithm
- Idea: simulate granting of grantable requests and check if initiator node is
  unblocked
- Variations:
  - Network with instant messages, base algorithm is static during deadlock
    detection
    - Needs `INᵤ, OUTᵤ, nᵤ` to be precalculated from the local state and
      channel states of a globally consistent snapshot
  - Network with time delays in message delivery, base algorithm is static
    - Relaxes the need for the channel states to be used
  - Network with time delays, base algorithm is dynamic
    - Relaxes the need for the global snapshot to be precalculated, i.e.
      integrates taking snapshot with deadlock detection
  - We will only look at variation 1
- Get a spanning tree by virtually calling two nested echo algorithms
  - The first spanning tree is rooted at the initiator (using notify/done
    messages)
  - Nested spanning trees are rooted at each active node (using grant/ack
    messages)

```python
  def notify(u):
    """
    Traverse the tree, building a spanning tree. If we find a node that is not
    waiting on any resources (i.e. `u.n == 0`) call `grant()` on it.
    """
    u.notified = True
    for w in u.out:
      w ! NOTIFY
    if u.n == 0:
      grant(u)
    for w in u.out:
      w ? DONE

  def grant(u):
    """
    Grant the resource held by this node.
    """
    u.free = True
    for w in u.in:
      w ! GRANT
    for w in u.in:
      w ? ACK

  def receive(u, message):
    if message == NOTIFY:
      if not u.notified:
        notify(u)
      return DONE

    elif message == GRANT:
      if u.n > 0:
        u.n -= 1
        if u.n == 0:
          grant(u)
      return ACK
```
- Will say whether WFG is currently deadlocked, not if one will happen

