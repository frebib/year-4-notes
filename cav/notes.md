# Computer Aided Verification

# Syllabus
- Modelling sequential and parallel systems
  - Labeled transition systems (LTS)
  - Parallel computation
- Temporal logic
  - LTL, CTL, CTL\*
- Model checking
  - CTL model checking algorithms
  - Automata-theoretic model checking (LTL)
- Verification tools (SPIN)
  - Not on exam
- Advanced verification techniques
  - Bounded model checking

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
  - All traces where every state conforms to some proposition `φ`
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
 
