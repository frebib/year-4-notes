# Computer Aided Verification

# Syllabus
- Modelling sequential and parallel systems
  - Labeled transition systems (LTS)
  - Parallel composition
- Temporal logic
  - LTL, CTL, CTL\*
- Model checking
  - CTL model checking algorithms
  - Automata-theoretic model checking (LTL)
- Verification tools (SPIN)
  - Not on exam
- Advanced verification techniques
  - Bounded model checking via propositional satisfiability
  - Symbolic model checking
    - Not on exam
  - Probabilistic model checking
    - Not on exam

# Labeled Transition Systems (LTSs)
- A tuple `(S, Act, →, I, AP, L)` where
  - `S` is a set of states
  - `Act` is a set of actions
  - `→ ⊆ S x Act x S` is a transition relation
    - Given a state, if we perform this action, what state do we end up in?
  - `I ⊆ S` is a set of initial states
  - `AP` is a set of atomic propositions
    - Possible labels for a state
  - `L : S → 2^AP` is a labelling function
    - Given a state, what labels are active for it?
- A LTS is finite iff  `S`, `Act`, and `AP` are finite
- This module mostly assumes finite LTSs

## Transitions
- `s -α-> s'` iff `(s, α, s) ∈ →`
- Direct successors:
  - `Post(s, α) = {s' ∈ S | s -α-> s'}`
  - `Post(s) = union(Post(a, α) for α in Act)`
- Direct predecessors:
  - `Pre(s, α) = {s' ∈ S | s' -α-> s}`
  - `Pre(s) = union(Pre(a, α) for α in Act)`
- Terminal states
  - `s ∈ S` is terminal iff `Post(s) = ø`
  - This means no outgoing transitions

## Paths
- Sequence of alternating states and actions
  - i.e. `s₀α₀s₁α₁s₂α₂...` such that `sᵢ -αᵢ-> sᵢ₋₁`
- A finite path is a finite prefix of an infinite path
- Reachability
  - `s' ∈ S` is reachable from `s ∈ S` iff there is a finite path from `s`
    to `s'`
  - `s ∈ S` is a reachable state iff it is reachable from some `s₀ ∈ I`

## Nondeterminism
- Outcome of event is not known in advance
- e.g. 10% likelihood a message send fails
- Can resemble an abstraction of a system
- Can resemble interaction with another system (e.g. a human)

## Concurrency - Asynchronous
- We can model two LTSs working in parallel
- If `M₁, M₂` are LTSs, to asynchronously combine them, we write `M₁ ||| M₂`
- Each transition becomes whether `M₁` or `M₂` is moved forward one step
- Typically the actions/progressions are written as `α, β`
- Formally
  - `M₁, M₂` are LTSs
    - `Mᵢ = (Sᵢ, Actᵢ, →ᵢ, Iᵢ, APᵢ, Lᵢ)` for `i = [1, 2]`
  - `M₁ ||| M₂ = (S₁ x S₂, Act₁ ∪ Act₂, →', I₁ x I₂, AP₁ ∪ AP₂, L')` where
    - `L'((s₁, s₂)) = L₁(s₁) ∪ L₂(s₂)`
    - if `(s₁, α₁, s₁') ∈ →₁` then `((s₁, s₂), α₁, (s₁', s₂')) ∈ →'` for all
      `s₁ ∈ S₂, s₂ ∈ S₂` (and vice versa)

## Concurrency - Synchronous
- Written as `M₁ ||ₕ M₂`
  - Where `h ⊆ Act` is a set of handshake actions
- Synchronise only on actions in `h`
- Formally
  - Same as asynchronous, except from `→'`
  - if `(s₁, α, s₁') ∈ →₁ ^ (s₂, α, s₂') ∈ →₂` then `((s₁, s₂), α, (s₁', s₂') ∈
    →'`
- If we move actions from `h`, we start to see deadlocks in the system, because
  the combined LTS does not know what to do when an action occurs in one LTS but
  not the other

# Linear Time Properties
We say `M |= P` if `M` is a LTS and `P` is a property and `M` conforms to `P`.
Can also be written as `Traces(M) ⊆ P` (i.e. all possible traces of `M` are
captured by `P`).

## Traces
- Traces, up til now, were interleaved states and actions
- We can ignore actions, as they don't provide anything for linear time
  properties
  - Only need to know where we *can* end up, not *how*
- Even further, we don't especially care about the states, just the labels
- So a trace is now a series of sets of labels
  - `trace(π) = {s₀, α₀, s₁, α₁...}`
  - `= {s₀, s₁, s₂, s₃...}`
  - `= {L(s₀), L(s₁), L(s₂), L(s₃)...}`
  - `= {{a, b}, {a}, {b}, {}, {a, b}...}`

## Types of Linear Time Properties
- Invariants
  - Something good is always true
  - `InvariantProperty = {{A₀, A₁, A₂...} | Aᵢ |= φ}`
  - All traces where every state conforms to some propositional logic formula
    `φ`
    - This means no CTL/LTL in `φ`, just something of the form `a ^ b`
  - Can easily check - just ensure it is true for all reachable states
- Safety properties
  - A failure does not occur
  - We can define a bad prefix that summarises traces that break the property
  - All invariants are safety properties, but not all safety properties are
    invariants
    - "the traffic lights never both show green" i.e. `¬(g₁ ^ g₂)`
      - Invariant, but can be expressed as safety property
    - "`g₁` is always preceded by `g₂`"
      - Can not express as invariant
- Liveness properties
  - Something good happens in the long run
  - e.g. the program always eventually terminates
  - Does not rule out any prefixes
  - `LivenessProperty ⊆ (2^AP)^ω` is a liveness property if for all finite words
    `σ ∈ (2^AP)*`, there exists a infinite word `σ' ∈ (2^AP)^ω` such that `σσ' ∈
    LivenessProperty`

# Linear Temporal Logic (LTL)
```
ψ ::= true
    | a ∈ AP
    | ψ ^ ψ
    | ¬ψ
    | ○ ψ
    | ψ U ψ
    // The rest are derivable from the above
    | ψ v ψ
    | false
    | □ ψ
    | ◇ ψ
```

- `○ ψ`: Next
  - In the next state, `ψ` is true
  - `○ a ⇒ {?, a, ?, ...}`
- `ψ₁ U ψ₂`: Until
  - `ψ₂` is true eventually, and `ψ₂` is true until then
  - `a U b ⇒ {a^¬b, a^¬b, b, ?, ...}`
- `□ ψ`: Always
  - `ψ` is always true in all states
  - Equivalent to `false U ψ`
  - `□ a ⇒ {a, a, a, a, ...}`
- `◇ ψ`: Eventually
  - `ψ` will eventually be true
  - Equivalent to `true U ψ`
  - `◇ a ⇒ {¬a, ¬a, ¬a, a, ?, ...}`

## Expressing in LTL
- We can express invariants (`□ φ`)
- We can express safety properties (`□ (receive → ○ ack)`)
- We can express liveness properties (`◇ terminates`)
- Two formulas `ψ₁, ψ₂` are equivalent if they are satisfied by the same traces
  - `(ψ₁ ≡ ψ₂) ↔ (σ |= ψ₁ ↔ σ |= ψ₂)` for all traces `σ`

## Equivalences
- `□ ψ ≡ ¬◇¬ψ`, `◇ψ ≡ ¬□¬ψ`
- `□ □ ψ ≡ □ ψ`
- `◇ ψ ≡ ψ v (○ ◇ ψ)`
- `□(ψ₁ ^ ψ₂) ≡ (□ ψ₁) ^ (□ ψ₂)`
- `σ |= ¬ψ ↔ σ |≠ ψ`
  - However, `M |= ¬ψ ↔ M |≠ ψ` is **not** true
  - No trace in `M` satisfied `ψ` vs. not all traces in `M` satisfies `ψ`

# Computation Tree Logic (CTL)
- In CTL, impossible to express "for every execution, it is always possible to
  return to the initial state of the program"
- Therefore, we introduce CTL with two quantifiers:
  - `∀` for all paths
  - `∃` there exists a path

```
φ ::= true | a | φ ^ φ | ¬φ | ∀ψ | ∃ψ
ψ ::= ○ φ | φ U φ | ◇ φ | □ φ
```

## Equivalences
- `∀ψ ≡ ¬∃¬ψ`
- `∃ψ ≡ ¬∀¬ψ`

## Existential Normal Form (ENF)
New grammar:
```
φ ::= true | a | φ ^ φ | ¬φ | ∃ (○ φ) | ∃ (φ U φ) | ∃ (□ φ)
```
- No `ψ`, everything encapsulated in `φ`
- No `∀`, no `∃◇`
- Done using previously mentioned equivalences

## Expressiveness
- We've seen you can represent things in CTL that you can't in LTL
- However, you can't represent `◇□a` in CTL
- `∀◇∀□a` does not work
  - Consider a LTS with three states:
    - `s₀` where `L(s₀) = {a}`, has a loop and leads to `s₁`
    - `s₁` where `L(s₁) = {}`, leads to `s₂`
    - `s₂` where `L(s₂) = {a}`, has a loop
  - CTL formula would break because not all paths have always `a`
- Same for `∀□∃◇a`

## CTL*
Superset of CTL and LTL
```
φ ::= true | a | φ ^ φ | ¬φ | ∀ψ | ∃ψ
ψ ::= φ | ψ ^ ψ | ¬ψ | ○ ψ | ψ U ψ | ◇ ψ | □ ψ
```

## Fairness
- Introduce another LTS that picks which of the two other LTSs to execute
- So `M₁ ||| M₂` becomes `M₁ || F || M₂` where
  - `F` is the fairness LTS that choses between `M₁` and `M₂`
  - `||` uses the actions that need to be executed by either `M₁, M₂`

# CTL Model Checking
- Given an LTS `M`, and a CTL formula `φ`, check whether `M |= φ`
  - i.e. check whether `s |= φ` for all initials tates `s ∈ I`
  - Assume `M` is finite, and has no terminal states
- `Sat(φ)` is the satisfaction set for CTL formula `φ`
  - i.e. set of all states that satisfy `φ`
  - i.e. `Sat(φ) = {s ∈ S | s |= φ}`
- So we check if `I ⊆ Sat(φ)`

## Calculating `Sat(φ)`
- Done recursively
- Done on ENF

```
Sat(true) = S
Sat(a) = {s ∈ S | a ∈ L(s)}
Sat(φ₁ ^ φ₂) = Sat(φ₁) ∩ Sat(φ₂)
Sat(¬φ) = S \ Sat(φ)

// All states where one of the next states satisfies `φ`
Sat(∃ (○ φ)) = {s ∈ S | Post(s) ∩ Sat(φ) ≠ ∅}

// Uses graph search algorithms
Sat(∃ (φ₁ U φ₂)) = CheckExistsUntil(Sat(φ₁), Sat(φ₂))
Sat(∃ (□ φ)) = CheckExistsAlways(Sat(φ))
```

### Exists Until (`∃U`)
- Trying to calculate `∃ (φ₁ U φ₂)`
- Given `Sat(φ₁), Sat(φ₂)`
- Backwards search of the LTS from `Sat(φ₂)`
  - `T₀ := Sat(φ₂)`
  - `Tᵢ := Tᵢ₋₁ ∪ {s ∈ Sat(φ₁) | Post(s) ∩ Tᵢ₋₁ ≠ ∅}`
  - Until `Tᵢ = Tᵢ₋₁`
  - `Sat(∃U)` is the final `Tᵢ`

### Exists Always (`∃□`)
- Trying to calculate `∃ (□ φ)`
- Given `Sat(φ)`
- Again, backwards search of the LTS from `Sat(φ)`
  - `T₀ := Sat(φ)`
  - `Tᵢ := Tᵢ₋₁ ∩ {s ∈ Sat(φ | Post(s) ∩ Tᵢ₋₁ ≠ ∅}`
  - Until `Tᵢ = Tᵢ₋₁`
  - `Sat(∃□)` is the final `Tᵢ`
- Alternative: Strongly Connected Components (SCCs)
  - SSC is a maximal connected subgraph
  - Non-trivial SSC is an SSC with at least one transition
  - Remove all states not satisfying `φ` making `M'`
  - Find non-trivial SSCs in `M'`
  - `Sat(∃□)` is the set of states that can reach an SSC in `M'`

### Complexity
- `O(|M| * |φ|)`
- `|M|` numer of states + transitions
- `|φ|` number of operators

# Automata-based Model Checking

## Notation
- `w = {A₀, A₁, ..., Aₙ}`
  - Finite word over alphabet `Σ` where `Aᵢ ∈ Σ`
- `σ = {A₀, A₁, ...}`
  - Infinite word over alphabet `Σ` where `Aᵢ ∈ Σ`
- `w` is a prefix of `σ` with length `n`, ending at `Aₙ`
- `σ'` is a infinite suffix of `σ`, starting at `Aₙ`
- `Σ*` set of finite words over `Σ`
- `Σ^ω` set of infinite words over `Σ`

## Non-deterministic Finite Automata
- Tuple `α = (Q, Σ, δ, Q₀, F)` where
  - `Q` is a finite set of states
  - `Σ` is an alphabet (actions)
  - `δ : Q x Σ -> 2^Q` is a transition function
  - `Q₀ ⊆ Q` is a set of initial states
  - `F ⊆ Q` is a set of accept states
- There is an `A` transition from `q` to `q'`...
  - Written as `q -A-> q'`
  - If `q' ∈ δ(q, A)`
- There is a run of `α` on a finite word `w = {A₀, A₁, ...}` if
  - There is a sequence of states `{q₀, q₁, ...}` where
  - `q₀ ∈ Q₀` and `qᵢ -Aᵢ-> qᵢ₊₁` for all `i`
- An accepting run is an `w` that ends in some `q ∈ F`
  - Thus `w` is accepted
- The language of `α` is denoted by `L(α)`
- `α₁, α₂` are equivalent iff `L(α₁) = L(α₂)`
- `L` is a regular language iff `L = L(E)` for some regex `E`
- `L` is a regular language iff `L = L(α)` for some NFA `α`

## Regular Safety Properties
- Example
  - "A failure never occurs", `□ ¬ fail`
  - `AP = {fail}`, `2^AP = {∅, {fail}}`
  - NFA `α`:
    - `q₀`, `L(q₀) = ∅`, transition to self and `q₁`, initial state
    - `q₁`, `L(q₁) = {fail}`, accepting state
  - `L(α) = {{{fail}}, {∅, {fail}}, {∅, ∅, {fail}}, ...}`
  - `.*{fail}`

## Checking LTSs
- Given an LTS `M` and regular safety property `P`
  - `M |= P ↔ Traces(M) ⊆ P`
  - `M |= P ↔ Traces(M) ∩ BadPrefixes(P) = ∅`
- Given an LTS `M` and an NFA `α` that represents bad prefixes of P
  - `M |= P ↔ Traces(M) ∩ L(α) = ∅`
- We can construct the product of `M` and `α`, written as `M ⊙ α`
  - `M = (S, Act, →, I, AP, L)`
  - `α = (Q, Σ, δ, Q₀, F)`
  - `M ⊙ α = (S x Q, Act, →', I', {accept}, L')`
  - `I' = {(s₀, q) | s₀ ∈ I, q₀ -L(s₀)-> q, q₀ ∈ Q₀}`
  - `L'((s, q)) = if q ∈ F then {accept} else ∅`
  - `→'`:
    - If `s -act-> s'` and `q -L(s')-> q'`
    - Then `(s, q) -act-> (s', q')`
- Therefore:
  - `M |= P ↔ M ⊙ α |= □ ¬ accept`
  - i.e. if there's no reachable accept state in `M ⊙ α`

# `ω`-regular Languages
- A regular expression over `Σ` is defined as:
  - `E ::= ∅ | ε | A ∈ Σ | E + E | E.E | E*`
  - TODO: Does `E + E` mean or, and `E.E` mean concat?
- A `ω`-regular expression over `Σ` is defined as:
  - `G = E₀.(F₀)^ω + E₁.(F₁)^ω + ... + Eₙ.(Fₙ)^ω`
- `Lω(G) ⊆ Σ^ω` is the language of a `ω`-regular expression `G`
  - `Lω(G) = L(E₀).L(F₀)^ω ∪ L(E₁).L(F₁)^ω ∪ ... ∪ L(Eₙ).L(Fₙ)^ω`
- `L ⊆ Σ^ω` is a `ω`-regular language if
  - `L = Lω(G)` for some `ω`-regular expression `G`
- `P ⊆ (2^AP)^ω` is a `ω`-regular property if
  - `P` is a `ω`-regular language over 2^AP
- Example
  - `AP = {wait, crit}`
  - "`crit` is true infinitely often"
  - `((¬crit)*crit)^ω`

## Non-deterministic Buchi Automata (NBA)
- Identical syntactically to NFAs
- Acceptance condition changes
  - The accept state does not need to be visited once, but has to be visited
    inifinitely often
- Represent `ω`-regular languages

### Non-blocking NBAs
- An NBA is non-blocking if every symbol/action is available in every state
  - i.e. `δ(q, A) ≠ ∅` for all `q ∈ Q` and `A ∈ Σ`
- We can always convert a blocking NBA to a non-blocking NBA by adding a trap
  state:
  - All undefined actions lead to it
  - It loops unconditionally to itself

### Checking Against LTS
- We can do product of LTS and NBA, as with safety properties
- And then we need to find a reachable cycle in the product that contains an
  accepting state
- This means that there is a path in the LTS that satisfies the property the NBA
  describes
- This is **not** the procedure for checking the property on an LTS
- To check whether an LTS `M` satisfies an LTL property `ψ`:
  - `M |= ψ`
  - `Traces(M) ⊆ Words(ψ)`
  - `Traces(M) ∩ Words(¬ψ) = ∅`
  - `Traces(M) ∩ Lω(α)` where `α` is an NBA that represents `¬ω`
  - `M |= ψ` iff there is no accepting path (cycle) in `M ⊙ α`
- Complexity is `O(|M| * 2^(|ψ|))`

